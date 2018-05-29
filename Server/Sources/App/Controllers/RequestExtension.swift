//
//  CustomValidators.swift
//  App
//
//  Created by Harley.xk on 2018/5/21.
//  Copyright © 2018年 Harley. All rights reserved.
//

import Foundation
import Validation

extension Validator where T == String {
    /// Validates whether a `String` is a valid Chinese phone address.
    ///
    ///     try validations.add(\.email, .email)
    ///
    public static var phone: Validator<T> {
        return PhoneValidator().validator()
    }
    
    public static var password: Validator<T> {
        return PasswordValidator().validator()
    }
}

fileprivate class PasswordValidator: RegularExpressionValidator {
    /// See `ValidatorType`.
    public override var validatorReadable: String {
        return "a valid password"
    }
    
    /// Creates a new `EmailValidator`.
    public init() {
        super.init(regex: "^[0-9a-zA-Z!@#$%^&*._]{6,20}$")
    }
    
    override var validatorErrorMessage: String {
        return "密码必须为 6 到 20 位字母数字和标点符号"
    }
}

/// Validates whether a string is a valid email address.
fileprivate class PhoneValidator: RegularExpressionValidator {
    /// See `ValidatorType`.
    public override var validatorReadable: String {
        return "a valid phone number"
    }
    
    /// Creates a new `EmailValidator`.
    public init() {
        super.init(regex: "^(([+])\\d{1,4})*1[0-9][0-9]\\d{8}$")
    }
    
    override var validatorErrorMessage: String {
        return "is not a valid phone number"
    }
}

fileprivate class RegularExpressionValidator: ValidatorType {
    /// See `ValidatorType`.
    public var validatorReadable: String {
        return "match regular expression: \(regex)"
    }
    
    /// Creates a new `EmailValidator`.
    public init(regex: String) {
        self.regex = regex
    }
    
    private var regex: String
    
    var validatorErrorMessage: String {
        return "is not match regular expression: \(regex)"
    }
    
    /// See `Validator`.
    public func validate(_ s: String) throws {
        guard
            let _ = s.range(of: regex, options: [.regularExpression, .caseInsensitive])
            else {
                throw BasicValidationError(validatorErrorMessage)
        }
    }
}

