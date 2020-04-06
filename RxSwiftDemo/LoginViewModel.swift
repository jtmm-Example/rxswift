//
//  LoginViewModel.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/6.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewModel {
    
    let disposeBag = DisposeBag()
    
    /// 登陆结果的信号
    let resultCommond = PublishSubject<String>()
    /// 登陆请求的信号
    let loginCommond = PublishSubject<[String: Any]>()
    
    init() {
        /// 网络请求
        loginCommond.subscribe(onNext: { (par) in
            
            rxNetworkRequest(MultiTarget(API.login(parameter: par)))
                .subscribe(onNext: { [weak self] (response) in
                    
                    guard let response = response as?[String:Any] else {
                        self?.resultCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    
                    guard let responseModel = Completion.deserialize(from: response) else {
                        self?.resultCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    
                    guard let result = responseModel.response as?[String:Any] else {
                        self?.resultCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    
                    guard let code = result["code"] as? NSNumber else {
                        self?.resultCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    if code == 200 {
                        self?.resultCommond.onNext("200")
                    } else {
                        let data : NSData! = try? JSONSerialization.data(withJSONObject: result, options: []) as NSData
                        let JSONString: String = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue) as String? ?? ""
                        print("请求结果：\(result)")
                        self?.resultCommond.onNext(JSONString)
                    }
                    
                }, onError: { (error) in
                    self.resultCommond.onError(error)
                    print(error.localizedDescription)
                }).disposed(by: self.disposeBag)
            
            }).disposed(by: disposeBag)
    }
    
}
