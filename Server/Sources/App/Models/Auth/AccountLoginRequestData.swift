//
//  AccountLoginRequestData.swift
//  App
//
//  Created by Harley.xk on 2018/5/29.
//

import Vapor

struct AccountLoginRequestData: Content, Validatable {
    static func validations() throws -> Validations<AccountLoginRequestData> {
        var validations = Validations(self)
        validations.add(\.account, at: ["Account"], .email || .phone)
        validations.add(\.password, at: ["password"], .password)
        return validations
    }
    
    var account: String
    var password: String
    
    enum AccountType {
        case email
        case phone
        case unknown
        
        var name: String {
            switch self {
            case .email: return "邮箱账号"
            case .phone: return "手机账号"
            default: return "未知账号"
            }
        }
    }
    
    var accountType: AccountType {
        do {
            try Validator.phone.validate(account)
            return .phone
        } catch { }
        do {
            try Validator.email.validate(account)
            return .email
        } catch { }
        return .unknown
    }
}

