//
//  CaptchaBody.swift
//  App
//
//  Created by Harley.xk on 2018/5/26.
//

import Vapor
import FluentMySQL
import Crypto

struct CaptchaRequest: Content, Validatable {
    static func validations() throws -> Validations<CaptchaRequest> {
        var validations = Validations(self)
        validations.add(\.phone, at: ["phone"], .phone)
        return validations
    }
    
    var phone: String
}

struct CaptchaBody: Content {
    
    struct Tel: Content {
        var mobile: String
        var nationcode: String
    }
    
    var params: [String]
    var sig: String
    //    let sign = "神笔马良"
    var tel: Tel
    let time: Int = Int(Date().timeIntervalSince1970)
    let tpl_id = "127823"
    
    init(phone: String, nation: String = "86", captcha: String, random: String) throws {
        params = [captcha, "10"]
        let sigResource = "appkey=\(Tencent_SMS_App_Secret)&random=\(random)&time=\(time)&mobile=\(phone)"
//        print("smsRes: \(sigResource)")
        sig = try SHA256.hash(sigResource).hexEncodedString()
//        print("smsSig: \(sig)")
        tel = Tel(mobile: phone, nationcode: nation)
    }
}


