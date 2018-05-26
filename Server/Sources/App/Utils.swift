//
//  ModelUtil.swift
//  App
//
//  Created by Harley.xk on 2018/5/25.
//

import Foundation
import Vapor
import Random

extension Encodable {
    public func encodeToJsonBody(use encoder: JSONEncoder = JSONEncoder()) throws -> HTTPBody {
        let data = try encoder.encode(self)
        return HTTPBody(data: data)
    }
}

/// 生成指定位数的验证码
///
/// - Parameter length: 验证码长度，第一位保证不为 0
public func GenerateCaptcha(length: Int = 6) -> String {
    let s = powf(10, Float(length))
    var result = arc4random() % UInt32(s)
    if result < 100000 {
        result += 100000
    }
    return "\(result)"
}

extension String {
    public static func random(bytes: Int = 6) -> String {
        return OSRandom().generateData(count: bytes).base64EncodedString()
    }
}
