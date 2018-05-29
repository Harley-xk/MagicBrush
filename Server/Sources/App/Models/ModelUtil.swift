//
//  ModelUtil.swift
//  App
//
//  Created by Harley.xk on 2018/5/29.
//

import Vapor

extension Encodable {
    public func encodeToJsonBody(use encoder: JSONEncoder = JSONEncoder()) throws -> HTTPBody {
        let data = try encoder.encode(self)
        return HTTPBody(data: data)
    }
}

final class RequestData<M: Content>: Content {
    var device: UserDevice?
    var data: M
    
    init(data: M, device: UserDevice?) {
        self.data = data
        self.device = device
    }
}
