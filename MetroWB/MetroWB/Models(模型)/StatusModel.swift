//
//  StatusModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/27.
//

import UIKit
import HandyJSON
import YYText

/// 微博模型
class StatusModel: HandyJSON {

    // id  int64 基础数据类型必须有初始值。 与int相比兼容性更好 保证在非64位的机器上成功运行
    var id:Int64 = 0
    // text
    var text:String?
    // user
    var user: UserModel?
    var reposts_count:Int = 0//    转发数
    var comments_count:Int = 0    //评论数
    var attitudes_count:Int = 0    //表态数
    
    // 微博配图数组
    var pic_urls:[StatusPicsModel]?
    // 被转发微博
    var retweeted_status: StatusModel?
    // 微博日期
    var created_at:String?
    // 微博来源
    var source: String?
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
    
    // 是否包含视频
    var isContentVideo:Bool = false
    // 包含链接的字段数组
    var linkArray:[[NSRange: ShortUrlInfoModel]]?
    // 视频是否是竖版
    var isVeritical:Bool = false
    // 视频模型
    var videoModel:ObjectModel?
    // 是否收藏
    var favorited:Bool = false
    
    // 如果文本中包含 全文  那么后面的内容将不显示 点击查看全文后显示
    var textString:String {
        
        var str = self.text!.replacingOccurrences(of: "]h", with: "] h")
        let suRange = (str as NSString).range(of: "...全文")
        if suRange.location != NSNotFound {
            let suS = (str as NSString).substring(to: (suRange.location + suRange.length))
            str = suS
        }
        
        return  isShowAll ? self.text!.replacingOccurrences(of: "]h", with: "] h") : str
    }
    
    // 是否显示全部内容 设计到截取 ...全文之后的内容
    var isShowAll = false
    
    required init(){}
    
    
    
    // 计算高度 在@我的界面使用
    func getHeightForAtMe()->CGFloat {
        let tempStr = self.textString
      
        let status_h:CGFloat = (264 + tempStr.heightForContent(width: ConstFile.ScreenW-40, font: ConstFile.status_text_font))
        
        return status_h
    }
    
    
    // 计算高度
    func getHeight()-> CGFloat{
        
        let tempStr = self.textString
        
        
        let picH: CGFloat = getPicsHeight(picCount: self.pic_urls == nil ? 0 : self.pic_urls!.count)
        let RepH: CGFloat = getRepostHeight()
        
        // 转成 NSMutableAttributedString
        var attributeString = NSMutableAttributedString(string: tempStr)
        
        // 设置富文本属性
        attributeString.yy_font = ConstFile.status_text_font
        attributeString.yy_kern = ConstFile.status_text_kern as NSNumber
        attributeString.yy_lineSpacing = ConstFile.text_marging
        attributeString.yy_color = ConstFile.gloab_font_color
        
         // 替换链接 视频或网页链接
        let tuple = RichTxtTool.setupAttributestring(m: self, attributeString: attributeString)
        self.videoModel = tuple.2
        attributeString = tuple.1
        
   
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        
        var status_h:CGFloat = (124 + attributeString.string.heightForContent(width: ConstFile.ScreenW-40, font: ConstFile.status_text_font))
        
        // 如果有p图片或者转发的微博 那么整个微博的高度要响应增加
        // 注意有时候p图片与视频并存 这时候只显示图片
        if picH > 0 {
            status_h += picH
            status_h += 5
        }else if isContentVideo {
            status_h += isVeritical ? 350 : 220
        }
        
        if RepH > 0 {
            status_h += RepH
            status_h += 20
        }
        
        return status_h
    }
    
    // 获取转发微博的高度 因为布局不同 所以单独计算
    func getRepostHeight()-> CGFloat{
        
        var h:CGFloat = 0
        if let repostS = self.retweeted_status  {
            
            let str = "@" + repostS.user!.screen_name! + ": " + repostS.textString
            
            // 转成 NSMutableAttributedString
            var attributeString = NSMutableAttributedString(string: str)
            
            // 设置富文本属性
            attributeString.yy_font = ConstFile.status_repost_text_font
            attributeString.yy_kern = ConstFile.status_text_kern as NSNumber
            attributeString.yy_lineSpacing = ConstFile.text_marging
            attributeString.yy_color = ConstFile.gloab_sub_font_color
            
            // 替换链接 视频或网页链接
            let tuple = RichTxtTool.setupAttributestring(m: repostS, attributeString: attributeString)
            self.videoModel = tuple.2
            attributeString = tuple.1
            

            // 替换表情
            let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_repost_text_font)
            attributeString = NSMutableAttributedString(attributedString: attribute)
            
             h = attributeString.string.heightForContent(width: ConstFile.ScreenW-60, font: ConstFile.status_repost_text_font)
            
            if repostS.pic_urls != nil && repostS.pic_urls!.count > 0 {
             h += getPicsHeight(picCount: repostS.pic_urls!.count)
             h += 5
            }else if repostS.isContentVideo {
                h += repostS.isVeritical ? (ConstFile.VIDEO_HEIGHT + 10) : 230
            }
            
            return h + 0
        }else {
            return 0
        }
    }
    
    /// 获取照片高度 1-3张是一行  4-6张是两行 7-9张是三行
    func getPicsHeight(picCount : Int)->CGFloat{
        
        let pics = picCount
        
        // 单张照片的宽高 左右间距20 照片间距5
        let wh = (ConstFile.ScreenW - 40 - 10)/3
        
        if pics == 0 {
            return 0
        }
        else if pics == 1 {// 一张照片要放大一些
            return 220
        }
            
        else if pics == 2 {
            return (ConstFile.ScreenW - 40 - 5)/2
        }
        // 1行
        else if pics < 4 {
            return 0 + wh
        }
        
        // 2行
        else if pics < 7 {
            return 5 + 2 * wh
        }
        // 3行
        return 10 + 3 * wh
    }
   
}
