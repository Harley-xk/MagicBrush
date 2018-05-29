//
//  LoginController.swift
//  App
//
//  Created by Harley.xk on 2018/5/29.
//

import Vapor
import FluentMySQL

final class LoginResponse: Content {
    var user: UserResp
    var token: TokenResp
    
    init(user: User, token: Token) {
        self.user = UserResp(from: user)
        self.token = TokenResp(from: token)
    }
}

class LoginController {
    
    /**
     * @api {post} auth/login 账号登录
     * @apiGroup Auth
     * @apiDescription 使用普通账号密码登录
     *
     * @apiParam {String} account 登录账号，支持手机号或者邮箱登录
     * @apiParam {String} password 密码
     *
     * @apiSuccess {Token} token 用户身份令牌
     * @apiSuccess {User} user 用户信息
     */

    func accountLogin(_ request: Request) throws -> Future<LoginResponse> {
        return try request.decode(AccountLoginRequestData.self).flatMap { requestData -> EventLoopFuture<LoginResponse> in
            let device = requestData.device!
            let data = requestData.data
            
            return request.newConnection(to: .mysql).flatMap({ (db) -> EventLoopFuture<[User]> in
                return try db.query(User.self).group(.and, closure: { (builder) in
                    try builder.group(.or, closure: { (bd) in
                        try bd.filter(\.phone == data.account)
                        try bd.filter(\.email == data.account)
                    })
                    let pass = try hashedPassword(data.password)
                    try builder.filter(\.password == pass)
                }).all()
            }).flatMap({ (users) -> Future<User> in
                guard let user = users.first else {
                    throw Abort(.unauthorized, reason: "用户名或密码错误")
                }
                let action = UserAction(userId: user.id ?? 0, actionType: .login, device: device, remark: "通过\(data.accountType.name)`\(data.account)`与密码登录")
                return action.save(on: request).transform(to: user)
            }).flatMap({ (user) -> Future<LoginResponse> in
                return try TokenController().createToken(for: user, device: device, on: request).map({ (token) -> (LoginResponse) in
                    return LoginResponse(user: user, token: token)
                })
            })
        }
    }
}
