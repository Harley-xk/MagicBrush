//
//  SMSResult.swift
//  App
//
//  Created by Harley.xk on 2018/5/26.
//

import FluentMySQL
import Vapor

struct SMSResult: Codable {
    
    var result: Int
    var errmsg: String
    var ext: String?
    var fee: Double?
    var sid: String?

    var succeed: Bool {
        return result == 0
    }
    
    static var SMSErrors: [Int: String] = [
        1008: "发送超时，请重试。",
        1013: "由于频率限制策略无法发送。",
        1023: "发送超时，请重试。",
        1008: "发送超时，请重试。",
        1008: "发送超时，请重试。",
        1008: "发送超时，请重试。",
        1008: "发送超时，请重试。",
        1008: "发送超时，请重试。",
    ]
    
    func abort() throws {
        switch result {
        // 0 发送成功
        case 0: return
        // 1008    请求下发短信/语音超时    出现概率很低，可重试解决
        case 1008: throw Abort(.requestTimeout, reason: "发送超时，请重试。")
        // 1013    请求下发短信/语音超时    出现概率很低，可重试解决
        case 1013: throw Abort(.tooManyRequests, reason: "由于频率限制策略无法发送。")
        // 1016    手机号码不存在或错误
        case 1016: throw Abort(.tooManyRequests, reason: "手机号码不存在或错误。")
        // 1023    单个手机号 30 秒内下发短信条数超过设定的上限
        case 1023: throw Abort(.tooManyRequests, reason: "该号码已达到 30 秒内发送短信数量上限，请稍后再试。")
        // 1024    单个手机号 1 小时内下发短信条数超过设定的上限
        case 1024: throw Abort(.tooManyRequests, reason: "该号码已达到 1 小时内发送短信数量上限，请稍后再试。")
        // 1025    单个手机号日下发短信条数超过设定的上限
        case 1025: throw Abort(.tooManyRequests, reason: "该号码已达到今日发送短信数量上限。")
        default:   throw Abort(.internalServerError, reason: "服务器内部错误（\(result)）")
        }
    }
}
