//
//  Migration.swift
//  App
//
//  Created by Harley.xk on 2018/5/24.
//

import Vapor
import FluentMySQL
import DatabaseKit
import MySQL

extension DatabaseIdentifier  {
    /// My custom DB.
    public static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return DatabaseIdentifier<MySQLDatabase>("MySQL-MaLiang")
    }
}


func makeMigrations(_ migrations: inout MigrationConfig) {
    
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: SocialAccount.self, database: .mysql)
    migrations.add(model: UserAction.self, database: .mysql)
    migrations.add(model: UserDevice.self, database: .mysql)
    
    migrations.add(model: CaptchaRecord.self, database: .mysql)
    
//    /// Currently Todo Only
    migrations.add(model: Todo.self, database: .mysql)

    
}
