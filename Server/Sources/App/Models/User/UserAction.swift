//
//  UserAction.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Vapor
import FluentMySQL

/// 记录用户操作行为的日志表，只记录重要行为
final class UserAction: MySQLModel, SoftDeletable {
    
    static var deletedAtKey: WritableKeyPath<UserAction, Date?> {
        return \.deletedAt
    }
    
    /// 软删除时间戳
    var deletedAt: Date?
    
    var id: Int?
    
    // 用户 id
    var user_id: Int
    
    // 操作类型
    var actionType: ActionType
    
    // 操作时间
    var time: Date
    
    // 备注信息
    var remark: String?
    
    // 操作使用的设备 id
    var deviceId: UserDevice.ID
    
    init(userId: Int, actionType: ActionType, device: UserDevice, remark: String? = nil) {
        self.user_id = userId
        self.actionType = actionType
        self.remark = remark
        self.time = Date()
        self.deviceId = device.id ?? -1
    }
}

extension UserAction: Migration {}
extension UserAction: Content {}

extension UserAction {
    
    enum ActionType: String, MySQLEnumType {
        static func reflectDecoded() throws -> (ActionType, ActionType) {
            return (.register, .login)
        }
        
        case register  // 注册
        case login     // 登录
    }
}
