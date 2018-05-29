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
    
    var mysqlConnection: Future<MySQLConnection> {
        return newConnection(to: .mysql)
    }
    
    func decodeUser() throws -> Future<User> {
        guard let t = http.headers["x-token"].first else {
            throw Abort(.unauthorized, reason: "无效的 Token")
        }
        return mysqlConnection.flatMap { (connection) -> EventLoopFuture<[User]> in
            try connection.query(Token.self).filter(\.value == t).all().flatMap({ (tokens) -> EventLoopFuture<[User]> in
                guard let token = tokens.first else {
                    throw Abort(.unauthorized, reason: "无效的 Token")
                }
                
                // 判断 token 绑定的 device 与发起请求的 device 是否一致
                guard let deviceUUID = self.http.headers["x-device"].first else {
                    throw Abort(.badRequest, reason: "Missing device info.")
                }
                if deviceUUID != token.device {
                    throw Abort(.unauthorized, reason: "无效的 Token")
                }
                
                // 判断 Token 是否过期
                let tokentime = Date().timeIntervalSince1970 - token.createTime.timeIntervalSince1970
                if tokentime > Double(Token_Avaliable_Length) * 60 {
                    throw Abort(.unauthorized, reason: "Token 已过期")
                }
                return try connection.query(User.self).filter(\.id == token.userId).all()
            })
            }.map { (users) -> (User) in
                guard let user = users.first else {
                    throw Abort(.unauthorized, reason: "无效的 Token")
                }
                return user
        }
    }
    
    func decodeDevice() throws -> UserDevice {
        guard let deviceBody = http.headers["x-device"].first, let data = deviceBody.data(using: .utf8) else {
            throw Abort(.badRequest, reason: "Missing device info.")
        }
        return try JSONDecoder().decode(UserDevice.self, from: data)
    }
    
    func updateDevice(_ device: UserDevice) throws -> Future<UserDevice> {
        return mysqlConnection.flatMap { (db) -> EventLoopFuture<[UserDevice]> in
            return try db.query(UserDevice.self).filter(\.uuid == device.uuid).all()
            }.flatMap { (devices) -> EventLoopFuture<UserDevice> in
                if let d = devices.first {
                    // 更新已存在的设备信息
                    device.id = d.id
                }
                return device.save(on: self)
        }
    }
    
    
    func decode<D>(_ content: D.Type, updateDevice: Bool = false, authed: Bool = true) throws -> Future<RequestData<D>> where D: Decodable {
        if !updateDevice, !authed {
            return try self.content.decode(D.self).map({ (data) -> RequestData<D> in
                return RequestData(data: data)
            })
        }
        
        return try self.content.decode(D.self).flatMap({ (data) -> Future<RequestData<D>> in
            let requestData = RequestData(data: data)
            var future: Future<RequestData<D>>?
            if updateDevice {
                let d = try self.decodeDevice()
                future = try self.updateDevice(d).map({ (device) -> (RequestData<D>) in
                    requestData.device = device
                    return requestData
                })
            }
            if authed {
                let authFuture = try self.decodeUser().map({ (user) -> (RequestData<D>) in
                    requestData.user = user
                    return requestData
                })
                if let f = future {
                    return authFuture.flatMap({ (data) -> EventLoopFuture<RequestData<D>> in
                        return f
                    })
                } else {
                    return authFuture
                }
            }
            guard let f = future else {
                throw Abort(.internalServerError)
            }
            return f
        })
    }
}
