//
//  DeviceInfoMiddleware.swift
//  App
//
//  Created by Harley.xk on 2018/5/26.
//

import Vapor
import Service
import FluentMySQL

extension Request {
    var device: UserDevice? {
        if let uuid = http.headers["x-device-uuid"].first,
            let name = http.headers["x-device-name"].first,
            let system = http.headers["x-device-system"].first,
            let model = http.headers["x-device-model"].first
        {
            return UserDevice(id: nil, uuid: uuid, name: name, system: system, model: model)
        }
        return nil
    }
    
    func decode<D>(_ content: D.Type, maxSize: Int = 65_536, withDevice: Bool = true) throws -> Future<(D, UserDevice)> where D: Decodable {
        var device = self.device
        if withDevice && device == nil {
            throw Abort(.badRequest, reason: "Missing device info.")
        }
        
        return newConnection(to: .mysql).flatMap({ (db) -> EventLoopFuture<[UserDevice]> in
            // 查询设备信息
            try db.query(UserDevice.self).filter(\.uuid == device?.uuid).all()
        }).flatMap { (devices) -> EventLoopFuture<UserDevice> in
            if devices.count <= 0 {
                // 保存设备信息
                return device!.save(on: self)
            } else {
                // 更新已存在的设备信息
                device!.id = devices.first!.id
                return device!.update(on: self)
            }
            }.flatMap { (device) -> EventLoopFuture<(D, UserDevice)> in
                return try self.content.decode(D.self).map({ (d) -> (D, UserDevice) in
                    return (d, device)
                })
        }
    }
}

final class DeviceInfoMiddleware: Middleware, ServiceType {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let _ = request.device else {
            throw Abort(.badRequest, reason: "Missing device info.")
        }
        return try next.respond(to: request)
    }
    
    static func makeService(for worker: Container) throws -> DeviceInfoMiddleware {
        return DeviceInfoMiddleware()
    }
    
    static var serviceSupports: [Any.Type] {
        return [self]
    }
}
