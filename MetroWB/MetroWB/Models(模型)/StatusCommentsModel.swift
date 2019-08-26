//
//  StatusCommentsModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/27.
//

import UIKit
import HandyJSON
import YYText

/// 评论列表模型
class StatusCommentsModel: HandyJSON {

    // 评论模型列表
    var comments:[StatusCommentModel]!
    
    var previous_cursor:Int64!
    var next_cursor:Int64!
    // 总共几条评论
    var total_number:Int64!
    
    
    required init() {}
}

/// 评论模型
class StatusCommentModel: HandyJSON {
    
    
    
   // 返回值字段    字段类型    字段说明
    var created_at:String!//    string    评论创建时间
    var id:Int64!//    int64    评论的ID
    var text:String!//    string    评论的内容
    var source:String!//    string    评论的来源
    var user:UserModel!//    object    评论作者的用户信息字段 详细
    var mid:String!//    string    评论的MID
    var idstr:String!//    string    字符串型的评论ID
    var status :StatusModel!//   object    评论的微博信息字段 详细
    var reply_comment:StatusCommentModel?//    object    评论来源评论，当本评论属于对另一评论的回复时返回此字段
    
    
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
       
        let status_h:CGFloat = (72 + tempStr!.heightForContent(width: ConstFile.ScreenW-84, font: ConstFile.status_repost_text_font))
        
        return status_h
    }
    
    // 计算@我的界面用的高度 区别是
    func getHeightForAtMe()-> CGFloat{
        
        let tempStr = self.text
        
        let status_h:CGFloat = (264 + tempStr!.heightForContent(width: ConstFile.ScreenW-40, font: ConstFile.status_text_font))
        
        return status_h
    }
    
//    var heightForAtMe:CGFloat = 0
//    func loadHeightForAtMe(){
//        
//        let tempStr = self.text
//        
//        self.heightForAtMe = (264 + tempStr!.heightForContent(width: ConstFile.ScreenW-40, font: ConstFile.status_text_font))
//    }
}
