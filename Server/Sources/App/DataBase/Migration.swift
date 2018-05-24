//
//  Migration.swift
//  App
//
//  Created by Harley.xk on 2018/5/24.
//

import Vapor
import FluentMySQL

func makeMigrations(_ migrations: inout MigrationConfig) {
    
    /// Currently Todo Only
    migrations.add(model: Todo.self, database: .mysql)

    
}
