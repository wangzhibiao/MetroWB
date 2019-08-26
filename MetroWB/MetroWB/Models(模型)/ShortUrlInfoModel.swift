//
//  ShortUrlInfoModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/4.
//

import UIKit
import HandyJSON
import SwiftyJSON


// 链接类型枚举
enum UrlTypeString:String {
    case webpage // 网页链接
    case appitem // 微博热点
    case audio // 音乐 同video 用一样的图标
    case video // 视频
    case article//头条文章
}


/// 短连接详细信息模型
/// 根据信息可以确认短连接是 视频还是普通网页链接 还是投票等
class ShortUrlInfoModel: HandyJSON {

    var result:Bool!
    var url_short:String?// "http://t.cn/Ai0dpnl0",
    var url_long:String?// "https://video.weibo.com/show?fid=1034:4390281613625707",
    var transcode:Int!// 0,
    var description:String?// "",
    var annotations:[AnnotationModel]?
    var type:Int!// 39,
    var title:String?// "",
    var last_modified:Int64!// 1562208246
    
    
    required init() {
        
    }
}
