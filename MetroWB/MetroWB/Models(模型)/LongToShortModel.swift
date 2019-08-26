//
//  LongToShortModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/4.
//

import UIKit
import SwiftyJSON
import HandyJSON

/// 长链接转短连接模型
class LongToShortModel: HandyJSON {

    var url_short:String?// "http://t.cn/h4DwT1",
    var url_long:String?// "http://finance.sina.com.cn/",
    var type:Int!// 0,
    var result:Bool!// "true"
    required init() {
        
    }
}
