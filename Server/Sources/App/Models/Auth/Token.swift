//
//  Token.swift
//  App
//
//  Created by Harley.xk on 2018/5/29.
//

import Vapor
import FluentMySQL

final class Token: MySQLModel {
    var id: Int?
    
    // 用户 ID
    var userId: User.ID
    
    // 设备的 uuid，同一个 token 只能在一台设备上使用
    var device: String
    
    // Token 值，随机字符串
    var value: String
    
    // 创建时间
    var createTime: Date
    
    // 刷新时间
    var updateTime: Date
    
    // 刷新次数, 后期可能用来做安全限制
    var updateCount: Int = 0
    
    init(for user: User, device: UserDevice) throws {
        guard user.id != nil, device.id != nil else {
            throw Abort(.internalServerError)
        }
        self.value = String.random(bytes: 32)
        self.userId = user.id!
        self.device = device.uuid
        self.createTime = Date()
        self.updateTime = createTime
    }
    
    func update() {
        self.value = String.random(bytes: 32)
        self.updateTime = createTime
        self.updateCount += 1
    }
}

extension Token: Migration {}

final class TokenResp: Content {
    // 有效期，单位：分
    var avaliable: Int
    var value: String
    var createTime: Date

    init(from token: Token) {
        value = token.value
        createTime = token.createTime
        avaliable = Token_Avaliable_Length
    }
}
