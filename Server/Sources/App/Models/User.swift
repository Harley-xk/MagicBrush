//
//  User.swift
//  App
//
//  Created by Harley.xk on 2018/5/22.
//

import Vapor
import FluentMySQL

final class User: MySQLModel {
    var id: Int?
    
    var nickName: String?
    var avatar: String?
    var phone: String?
    var email: String?
    var password: Data
}

