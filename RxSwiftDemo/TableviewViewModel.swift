//
//  TableviewViewModel.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/4.
//  Copyright © 2020 tiens. All rights reserved.
//

import Foundation

struct requestError: Error {
    let message: String
}

class TableviewViewModel {
    
    let disposeBag = DisposeBag()
    
    /// 开始刷新的信号
    let reloadCommond = PublishSubject<[cellModel]>()
    /// 开始请求的信号
    let requestCommond = PublishSubject<[String: Any]>()
    
    init() {
        /// 网络请求
        requestCommond.subscribe(onNext: { (par) in
            
            rxNetworkRequest(MultiTarget(API.list(parameter: par)))
                .subscribe(onNext: { [weak self] (response) in
                    
                    guard let response = response as?[String:Any] else {
                        self?.reloadCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    
                    guard let responseModel = Completion.deserialize(from: response) else {
                        self?.reloadCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    
                    guard let reesult = responseModel.response as?[String:Any],let dataArray = reesult["result"] as?[[String:Any]] else {
                        self?.reloadCommond.onError(requestError(message: "解析失败"))
                        return
                    }
                    var sourceArray: [cellModel] = []
                    
                    for dict in dataArray {
                        guard let model = cellModel.deserialize(from: dict)else{continue}
                        sourceArray.append(model)
                    }
                    
                    self?.reloadCommond.onNext(sourceArray)
                    
                }).disposed(by: self.disposeBag)
            
            }).disposed(by: disposeBag)
    }
    
}
