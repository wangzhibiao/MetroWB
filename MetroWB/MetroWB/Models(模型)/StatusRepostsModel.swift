//
//  StatusRepostsModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/27.
//

import UIKit
import HandyJSON
import YYText

/// 转发列表模型
class StatusRepostsModel: HandyJSON {
    
    // 评论模型列表
    var reposts:[StatusRepostModel]!
    
    var previous_cursor:Int64?
    var next_cursor:Int64?
    // 总共几条
    var total_number:Int64!
    
    
    required init() {}
}

/// 转发模型
class StatusRepostModel: HandyJSON {
    
    // 返回值字段    字段类型    字段说明
     
    var idstr:String!//    string    字符串型的微博ID
    var created_at:String!//    string    创建时间
    var id:Int64!//    int64    微博ID
    var text:String!//    string    微博信息内容
    var source:String!//    string    微博来源
    var favorited:Bool!//    boolean    是否已收藏
    var truncated:Bool!//    boolean    是否被截断
    var in_reply_to_status_id:Int64!//    int64    （暂未支持）回复ID
    var in_reply_to_user_id:Int64!//    int64    （暂未支持）回复人UID
    var in_reply_to_screen_name:String!//    string    （暂未支持）回复人昵称
    var mid:Int64!//    int64    微博MID
    var bmiddle_pic:String!//    string    中等尺寸图片地址
    var original_pic:String!//    string    原始图片地址
    var thumbnail_pic:String!//    string    缩略图片地址
    var reposts_count:Int64!//    int    转发数
    var comments_count:Int64!//    int    评论数
//    var annotations:    array    微博附加注释信息
    var geo:AnyObject?//    object    地理信息字段
    var user:UserModel!//    object    微博作者的用户信息字段
    var retweeted_status:StatusModel!//    object    转发的微博信息字段
     
    
    
    required init(){}
    
    // 格式化来源
    var sourceTxt:String {
        
        let result = source ?? ""
        if result == ""{
            return result
        }
        let last = source!.lastIndex(of: "<") ?? source!.endIndex
        let first = source!.firstIndex(of: ">") ?? source!.startIndex
        var src  = result[first..<last]
        src.remove(at: src.startIndex)
        return "来自\(src)"
    }
    // 格式化日期
    var createAtTxt:String {
        return Date.sinaDate(string: created_at!)?.dateDescription ?? "悄悄的"
    }
    
    // 计算高度
    func getHeight()-> CGFloat{
        
        let tempStr = self.text
        
        let status_h:CGFloat = (104 + tempStr!.heightForContent(width: ConstFile.ScreenW-40, font: ConstFile.status_text_font))
        
        return status_h
    }
}
