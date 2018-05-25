//
//  SocialAccount.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Vapor
import FluentMySQL


/// 用户绑定的社交账号表
struct SocialAccount: MySQLModel {
    
    /// 账号 id
    var id: Int?
    
    // 账号所属用户的 id
    var userId: User.ID
    
    /// 账号所属平台
    var platform: Platform
    
    /// 账号在对应平台的 id
    var openId: String
    
    // 创建时间，即绑定该账号的时间
    var createTime: Date
}

extension SocialAccount {
    enum Platform: String, MySQLEnumType {
        static func reflectDecoded() throws -> (SocialAccount.Platform, SocialAccount.Platform) {
            return (.wechat, .QQ)
        }
        
        case wechat
        case QQ
    }
}

extension SocialAccount: Migration {}
extension SocialAccount: Content {}

