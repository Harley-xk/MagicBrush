//
//  Migration.swift
//  App
//
//  Created by Harley.xk on 2018/5/24.
//

import Vapor
import FluentMySQL

func makeMigrations(_ migrations: inout MigrationConfig) {
    
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: SocialAccount.self, database: .mysql)
    migrations.add(model: UserActionRecord.self, database: .mysql)
    migrations.add(model: UserDevice.self, database: .mysql)
    
//    /// Currently Todo Only
    migrations.add(model: Todo.self, database: .mysql)

    
}
