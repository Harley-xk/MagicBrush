//
//  RegisterController.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Vapor
import FluentMySQL

struct PhoneRegisterRequest: Codable, Validatable {
    var nickname: String
    var phone: String
    var captcha: String
    var password: String
    
    static func validations() throws -> Validations<PhoneRegisterRequest> {
        var validations = Validations(self)
        validations.add(\.phone, at: ["phone"], .phone)
        validations.add(\.password, at: ["password"], .count(6...20))
        return validations
    }
}

class RegisterController {
    
    /**
     * @api {post} auth/mobile-register 手机号注册
     * @apiParam 使用手机号注册账号，需要在头部携带设备信息
     * @apiGroup Auth
     *
     * @apiParam {String} phone 手机号码
     * @apiParam {String} captha 验证码，通过`sms/captcha`接口获得
     * @apiParam {String} nickname 用户昵称，昵称可重复
     * @apiParam {String} passowrd 密码，6-20 位字符、数字和标点符号，前端需要做二次密码校验
     *
     * @apiSuccess {User} -- 注册成功返回用户信息
     */
    func phoneRegister(_ request: Request) throws -> Future<UserResp> {
        
        return try request.content.decode(PhoneRegisterRequest.self).flatMap({ (data) -> Future<UserResp> in
            try data.validate()
            return SMSController().verifyCaptcha(data.captcha, with: data.phone, on: request).flatMap({ (passed) -> EventLoopFuture<MySQLConnection> in
                if !passed {
                    throw Abort(.badRequest, reason: "验证码不正确。")
                }
                return request.newConnection(to: .mysql)
            }).flatMap({ (connection) -> EventLoopFuture<[User]> in
                return try connection.query(User.self).filter(\.phone == data.phone).all()
            }).flatMap({ (users) -> EventLoopFuture<User> in
                if users.count > 0 {
                    throw Abort(.conflict, reason: "该手机号已注册。")
                } else {
                    let user = try User(phone: data.phone, nickname: data.nickname, password: data.password)
                    return user.save(on: request)
                }
            }).flatMap({ (user) -> EventLoopFuture<User> in
                guard let device = request.device else {
                    throw Abort(.badRequest, reason: "Missing device info.")
                }
                return device.save(on: request).flatMap({ (device) -> EventLoopFuture<UserAction> in
                    let action = UserAction(userId: user.id ?? 0, actionType: .register, device: device, remark: "通过手机号`\(data.phone)`注册")
                    return action.save(on: request)
                }).transform(to: user)
            }).map({ (user) -> (UserResp) in
                return UserResp(from: user)
            })
        })        
    }
}
