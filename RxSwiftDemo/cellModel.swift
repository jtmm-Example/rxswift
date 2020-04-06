//
//  cellModel.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/4.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit

class cellModel: HandyJSON {
    required init() {}
    
    /// 内容
    var content:String = ""
    /// 创建时间
    var created:String = ""
    /// 公告id
    var id:String = ""
    /// 是否置顶
    var isRecommend:Bool = false
    /// 修改时间
    var modified:String = ""
    /// 公告链接
    var noticeUrl:String = ""
    /// 标题
    var title:String = ""
    /// 公告类型  3：视频
    var type: Int = 99
}
