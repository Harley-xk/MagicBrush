//
//  DeviceInfoMiddleware.swift
//  App
//
//  Created by Harley.xk on 2018/5/26.
//

import Vapor
import Service

extension Request {
    var device: UserDevice? {
        if let uuid = http.headers["x-device-uuid"].first,
            let name = http.headers["x-device-name"].first,
            let system = http.headers["x-device-system"].first,
            let model = http.headers["x-device-model"].first
        {
            return UserDevice(id: -1, uuid: uuid, name: name, system: system, model: model)
        }
        return nil
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
