//
//  Account.swift
//  App
//
//  Created by Harley.xk on 2018/5/22.
//

import Vapor
import FluentMySQL

final class Account: MySQLModel {
    var id: Int?
    var email: String?
    var phone: String?
    var password: String
}

extension Account: Migration {
    
}
