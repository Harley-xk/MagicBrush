//
//  CaptchaRecord.swift
//  App
//
//  Created by Harley.xk on 2018/5/26.
//

import FluentMySQL
    
final class CaptchaRecord: MySQLModel {
    var id: Int?
    
    var phone: String
    var code: String
    var device: String
    var expireTime: Date
    
    init(phone: String, code: String, device: String) {
        self.phone = phone
        self.code = code
        self.device = device
        self.expireTime = Date().addingTimeInterval(600)
    }
}

extension CaptchaRecord: Migration {}
