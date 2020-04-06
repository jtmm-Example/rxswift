//
//  NetWorkManager.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/4.
//  Copyright © 2020 tiens. All rights reserved.
//

import Foundation
import Moya
import RxSwift

///请求结束的回调
public typealias finishedCallback = ((_ result: Any?, _ errorCode: Int?, _ success: Bool) -> (Void))

//TODO: 插件看情况在自定义
/// 请求体
private let moyaParvider = MoyaProvider<MultiTarget>()

public func netwrokRequest(_ target: MultiTarget, completion: @escaping finishedCallback) {
    
    moyaParvider.request(target) { (result) in
        
        switch result {
        case let .success(response):
            do {
                //过滤200-299的状态码
                let response = try response.filterSuccessfulStatusCodes()
                let data = try response.mapJSON()
                completion(data, response.statusCode, true)
            }
            catch {
                //响应状态码
                let statusCode: Int = response.statusCode
                completion(nil, statusCode, false)
            }
            
        case let .failure(error):
            completion(error.localizedDescription, error.errorCode, false)
        }
    }
}



class Completion: HandyJSON {
    required init() {
        
    }
    
    var response: Any?
    var succeess: Bool?
    var code: Int?
    
    init(response:Any?, succeess:Bool?, code:Int?) {
        self.response = response
        self.succeess = succeess
        self.code = code
    }
}

//TODO: 定义全局error状态码
//TODO: 把需要返回的数据 组装成一个对象，暂时没成功，如果用Codable与HandyJSON好像不太匹配
//TODO: 这个方法可有可无，放在vm里边 直接用moyaParvider的rx扩展
func rxNetworkRequest(_ target: MultiTarget) -> Observable<Any> {

    return Observable<Any>.create { (observer) -> Disposable in
        moyaParvider.request(target) { (result) in
            switch result {
            case .success(let value):
                do {
                    let value = try value.filterSuccessfulStatusCodes()
                    let data = try value.mapJSON()
                    let result: [String:Any] = Completion(response: data, succeess: true, code: value.statusCode).toJSON() ?? ["":""]
                    observer.onNext(result)
                    //TODO: 研究onNext为什么发送不了object
                } catch  {
                    observer.onError(error)
                }

            case .failure(let error):
                print("失败测试")
                observer.onError(error)
            }
        }
        return Disposables.create()
    }
}

