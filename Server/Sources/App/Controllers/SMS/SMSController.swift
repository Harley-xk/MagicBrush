//
//  SMSController.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Vapor
import FluentMySQL
import DatabaseKit

struct CaptchaResponse: Content {
    // 有效期，单位：分
    var avaliable: Int
    // 过期时间
    var expireTime: Double
}

/// 处理短信验证码的控制类
class SMSController {
    
    /**
     * @api {post} sms/captcha 发送短信验证码
     * @apiGroup SMS
     * @apiDescription 向指定设备发送短信验证码，需要在请求头部<span style="color:red;bold">**携带设备信息**</span>
     *
     * @apiParam {String} phone 接收短信的电话号码
     *
     * @apiSuccessExample 发送成功
     * HTTP/1.1 200 OK
     * {
     *    "expireTime": 1527556443.0491471,  // 验证码过期时间
     *    "avaliable": 10       // 验证码有效期，单位分钟
     * }
     */
    func postCaptcha(_ req: Request) throws -> Future<CaptchaResponse> {
        
        return try req.decode(CaptchaRequest.self, authed: false).flatMap({ reqData -> Future<CaptchaResponse> in
            let data = reqData.data
            let device = try req.decodeDevice()
            try data.validate()
            let phone = data.phone
            // 查询是否已经存在刚发送的验证码
            return req.mysqlConnection.flatMap { (connection) -> Future<[CaptchaRecord]> in
                return try connection.query(CaptchaRecord.self).group(.or, closure: { (builder) in
                    try builder.filter(\.phone == phone)
                    try builder.filter(\.device == device.uuid)
                }).all()
                }.flatMap({ (records) -> Future<CaptchaResponse> in
                    // 可能存在多个验证码，逐一比对并删除已过期的记录
                    for record in records {
                        let timePassed = Date().timeIntervalSince1970 - record.sendTime.timeIntervalSince1970
                        // 存在一分钟内发送的验证码，此时不能重复发送
                        if timePassed < 60 {
                            if record.phone != phone {
                                throw Abort(.tooManyRequests, reason: "该设备已申请发送验证码，请勿重复申请。")
                            }
                            throw Abort(.tooManyRequests, reason: "验证码已发送，请勿重复发送。")
                        } else {
                            // 删除所有指定手机号的验证码
                            if record.phone == phone {
                                _ = record.delete(on: req)
                            }
                        }
                    }
                    return try self.sendCaptcha(to: phone, on: req, with: device).map({ (result) -> (CaptchaResponse) in
                        try result.abort()
                        let expireTime = (result.captchaBody?.sendTime ?? Date()).timeIntervalSince1970 + 600
                        let resp = CaptchaResponse(avaliable: 10, expireTime: expireTime)
                        return resp
                    })
                })
        })
    }
    
    //向指定手机号发送短信验证码
    func sendCaptcha(to phone: String, on req: Request, with device: UserDevice) throws -> Future<SMSResult> {
        let random = String.random()
        let captcha = GenerateCaptcha()
        return try req.client().post("https://yun.tim.qq.com/v5/tlssmssvr/sendsms?sdkappid=\(Tencent_SMS_App_ID)&random=\(random)", headers: HTTPHeaders(), beforeSend: { (req) in
            let body = try CaptchaBody(phone: phone, captcha: captcha, random: random)
            req.http.body = try body.encodeToJsonBody()
        }).flatMap({ (resp) -> EventLoopFuture<SMSResult> in
            let result = try resp.content.decode(SMSResult.self)
            return result
        }).map({ (result) -> (SMSResult) in
            var rest = result
            if rest.succeed {
                print("\nCaptcha Send Successed! Code: \(captcha)\n")
                let record = CaptchaRecord(phone: phone, code: captcha, device: device.uuid)
                _ = record.save(on: req)
                rest.captchaBody = record
            } else {
                print("\nCaptcha Error: \(result.result) - \(result.errmsg)\n")
            }
            return rest
        })
    }
    
    /// 校验手机号和验证码是否有效
    func verifyCaptcha(_ captcha: String, with phone: String, on request: Request) -> Future<Bool> {
        // 查询是否已经存在刚发送的验证码
        return request.mysqlConnection.flatMap { (connection) -> EventLoopFuture<[CaptchaRecord]> in
            return try connection.query(CaptchaRecord.self).group(.and, closure: { (builder) in
                try builder.filter(\.phone == phone)
                try builder.filter(\.code == captcha)
            }).all()
        }.map { (records) -> (Bool) in
            for record in records {
                // 验证码未过期，校验通过
                let timePassed = Date().timeIntervalSince1970 - record.sendTime.timeIntervalSince1970
                if timePassed < 600 {
                    /// 校验通过，删除验证码
                    _ = record.delete(on: request)
                    return true
                }
            }
            return false
        }
    }
    
}
