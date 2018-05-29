//
//  UserDevice.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Vapor
import FluentMySQL

/// 用户使用的设备，所要在所有请求头部携带设备信息
struct UserDevice: MySQLModel, SoftDeletable {
    
    static var deletedAtKey: WritableKeyPath<UserDevice, Date?> {
        return \.deletedAt
    }
    
    /// 软删除时间戳
    var deletedAt: Date?
    
    var id: Int?
    
    // 设备唯一编号
    var uuid: String
    
    // 设备名称，用户自定义的设备名称
    var name: String
    
    // 系统名称及版本号：e.g. iOS 12、Android 8.0、Windows 10...
    var system: String
    
    // 设备型号, e.g. iPhone 6 plus、MI Mix 2S...
    var model: String
}

extension UserDevice: Migration {}
extension UserDevice: Content {}

