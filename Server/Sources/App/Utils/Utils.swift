//
//  ModelUtil.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Foundation
import Vapor
import Random
import Crypto

/// 加密用户密码
public func hashedPassword(_ pass: String) throws -> String {
    return try SHA256.hash(pass).hexEncodedString()
}

/// 生成指定位数的验证码
///
/// - Parameter length: 验证码长度，第一位保证不为 0
public func GenerateCaptcha(length: Int = 6) -> String {
    var captcha = ""
    for index in 0 ..< length {
        let random = RandomNumber(min: (index == 0 ? 1 : 0), max: 9)
        captcha.append("\(random)")
    }
    return captcha
}

public func RandomNumber(min: Int = 0, max: Int = 9) -> Int {
    let source = Array(min...max)
    return source.random ?? min
}

extension String {
    public static func random(bytes: Int = 6) -> String {
        return OSRandom().generateData(count: bytes).base64EncodedString()
    }
}
