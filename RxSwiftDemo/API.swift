//
//  API.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/4.
//  Copyright © 2020 tiens. All rights reserved.
//

import Foundation

public enum API {
    case login(parameter: [String: Any])
    case list(parameter: [String: Any])
}

extension API: TargetType {
    public var baseURL: URL {
        return URL(string: "https://mobilemall-dev.jtmm.com/mobile/")!
    }
    
    public var path: String {
        switch self {
        case .login:
            return "newLogin"
        case .list:
            return "home/getNoticeList"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .list:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .login(let parameter):
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
        case .list(let parameter):
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }
}
