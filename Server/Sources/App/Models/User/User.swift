//
//  User.swift
//  App
//
//  Created by Harley.xk on 2018/5/22.
//

import Vapor
import FluentMySQL
import Crypto

/// 用户表
final class User: MySQLModel {
    
    // 用户 id
    var id: Int?
    
    // 昵称可重复
    var nickname: String
    
    // 头像链接（绝对地址/相对地址，待定）
    var avatar: String?

    // hash 后的密码
    var password: String
    
    // 当前用户的注册渠道，不可修改
    private(set) var registerChannel: RegisterChannel
    
    // 手机号
    var phone: String?
    
    // 邮箱
    var email: String?
    
    // 创建时间、不可修改
    private(set) var createTime: Date = Date()
    
    // 更新时间
    var updateTime: Date?
    
    // 用户状态，初始为 pending
    var status: Status = .pending
    
    /// 通过手机号创建用户，需要先验证手机号
    convenience init(phone: String, nickname: String, password: String) throws {
        try self.init(nickname: nickname, password: password, registerChannel: .phone)
        self.phone = phone
        self.registerChannel = .phone
        self.status = .active
    }
    
    /// 通过邮箱创建用户
    convenience init(email: String, nickname: String, password: String) throws {
        try self.init(nickname: nickname, password: password, registerChannel: .email)
        self.email = email
        self.registerChannel = .email
    }

    private init(nickname nk: String, password pwd: String, registerChannel channel: RegisterChannel) throws {
        nickname = nk
        password = try SHA256.hash(pwd).hexEncodedString()
        registerChannel = channel
    }
}

extension User {
    // 注册渠道，可扩展
    enum RegisterChannel: String, MySQLEnumType {
        case phone
        case email
        case wechat
        
        static func reflectDecoded() throws -> (User.RegisterChannel, User.RegisterChannel) {
            return (.phone, .email)
        }
    }
    
    // 用户状态
    enum Status: String, MySQLEnumType {
        case pending // 等待激活
        case active // 活跃状态
        case banned // 封禁
        
        static func reflectDecoded() throws -> (User.Status, User.Status) {
            return (.pending, .active)
        }
    }
}

extension User: Migration {}

/// 用于返回的用户信对象，去除敏感信息
struct UserResp: Content {
    var id: Int
    
    let nickName: String
    var avatar: String?
    var phone: String?
    var email: String?
    
    var createTime: Date
    var updateTime: Date?
    
    init(from user: User) {
        id = user.id ?? 0
        nickName = user.nickname
        avatar = user.avatar
        phone = user.phone
        email = user.email
        createTime = user.createTime
        updateTime = user.updateTime
    }
}

