//
//  TokenController.swift
//  App
//
//  Created by Harley.xk on 2018/5/29.
//

import Vapor
import FluentMySQL

final class TokenController {
    
    func createToken(for user: User, device: UserDevice, on req: Request) throws -> Future<Token> {
        
        return req.mysqlConnection.flatMap { (connection) -> EventLoopFuture<[Token]> in
            return try connection.query(Token.self).group(.and, closure: { (builder) in
                try builder.filter(\.userId == user.id)
                try builder.filter(\.device == device.uuid)
            }).all()
            }.flatMap { (tokens) -> EventLoopFuture<Token> in
                for token in tokens {
                    _ = token.delete(on: req)
                }
                let token = try Token(for: user, device: device)
                return token.save(on: req)
        }
    }
    
    func updateToken(_ token: Token, on req: Request) -> Future<Token> {
        token.update()
        return token.save(on: req)
    }
    
}
