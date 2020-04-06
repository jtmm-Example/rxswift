//
//  LoginViewModel.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/6.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit
import RxSwift

/// 请求体
private let moyaParvider = MoyaProvider<MultiTarget>()

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
                    //TODO: 也可以中做直接转模型的扩展，
                    
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
    
    
    //TODO: 现在项目的方式
    // 或者返回Observable
    func rxMoyaParvider(parameter: [String: Any], finished:@escaping (_ success:Bool) ->()) {
        moyaParvider
            .rx
            .request(MultiTarget(API.login(parameter: parameter)))
        .asObservable()
            // 请求就可以转model：mapHandyJsonModel
            .mapHandyJsonModel(jsonModel.self)
            .map({ (model) in
                //TODO:如果要返回Observable，在这做model处理，然后转换成Observable
            })
            //.asObservable()
            .subscribe(onNext: { (model) in
                finished(true)
            }, onError: { (error) in
                finished(false)
            })
            
//            .subscribe(onSuccess: { (response) in
//                //TODO: 数据处理
//                finished(true)
//            }) { (error) in
//                //TODO: 数据处理
//                 finished(false)
//            }
            .disposed(by: self.disposeBag)
    }
    
}

class jsonModel: HandyJSON {
    required init() {}
}


//TODO: model转换的方法
extension ObservableType where E == Response {
    public func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapHandyJsonModel(T.self))
        }
    }
}

extension Response {
    func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonString = String.init(data: data, encoding: .utf8)
        if let modelT = JSONDeserializer<T>.deserializeFrom(json: jsonString) {
            return modelT
        }
        return JSONDeserializer<T>.deserializeFrom(json: "{\"msg\":\"请求有误\"}")!
    }
}
