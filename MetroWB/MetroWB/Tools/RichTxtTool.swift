//
//  RichTxtTool.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/6.
//

import Foundation
import UIKit
import YYText
import WebKit
import SwiftyJSON
import HandyJSON

/// 富文本工具 包括高亮 点击链接 不同颜色等
class RichTxtTool {
    
    
    /// 替换链接为 网址链接
    static func resetLink( strM:  NSMutableAttributedString, completed: @escaping ([[NSRange: ShortUrlInfoModel]]?)->()){
        
        let str = strM.string
        let regex = try! NSRegularExpression(pattern: ConstFile.reg_string_url, options: [])
        
        //2.通过规则在字符串中查找目标字符串
        let results = regex.matches(in: str, options: [], range: NSRange(location: 0, length: strM.length))
        var dictArray = [[NSRange: ShortUrlInfoModel]]()
        
        // 没有匹配到url
        if results.count > 0 {
            
            // 匹配到url数组
            let regxGroup = DispatchGroup()
            let regxQuene = DispatchQueue(label: "regxQuene")
            
            for result in results{
                
                regxGroup.enter()
                // 范围
                let range = result.range(at: 0)
                // 对应str
                let subStr = (str as NSString).substring(with: range)
                // 短连接
                if subStr.isShortUrl {
                    MTNetWorkTools.shared.ShortUrlDetialRequest(shortUrl: subStr, success: { (json) in
                        
                        let dict = JSON(parseJSON: json)
                        if let result = [ShortUrlInfoModel].deserialize(from: dict["urls"].rawString())  {
//                            print("--urls : \(json)")
                            if let rest = result.first {
                                dictArray.insert([range: rest!], at: 0)//append([range: rest!])
                                regxGroup.leave()
                            }
                        }
                        
                    }) { (error) in
                        regxGroup.leave()
                    }
                    
                }else {// 长链接 直接返回空模型 前台替换为 网页链接
                    
                    dictArray.insert([range: ShortUrlInfoModel()], at: 0)//append([range: ShortUrlInfoModel()])
                    regxGroup.leave()
                }
            }
            
            // 所有url 匹配完成
            regxGroup.notify(queue: regxQuene) {
                dictArray.sort(by: { (dict1, dict2) -> Bool in
                   return dict1.keys.first!.location > dict2.keys.first!.location
                })
                completed(dictArray)
            }
        }
        else{// 没有匹配到url
            completed(nil)
        }
        
    }
    
    
    
    
    /// 默认方法 将@某人 话题## 链接 都高亮
    static func addHighlightedAll(strM:inout NSMutableAttributedString, isAll: Bool = false, font: UIFont = ConstFile.status_text_font, specTxt: [String] = ["(\\... 全文)"], defaultColor: UIColor = ConstFile.gloab_font_color){
        
         strM.yy_color = defaultColor
        
        let str = strM.string
        
        // 正则数组
        var regxs = [ConstFile.reg_string_url,ConstFile.reg_string_emj,ConstFile.reg_string_user,ConstFile.reg_string_huati]
        
        for str in specTxt {
            regxs.append(str)
        }
        
        // 循环匹配
        for item in regxs {
            
            let regex = try! NSRegularExpression(pattern: item, options: [])
           
            //2.通过规则在字符串中查找目标字符串
            let results = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
            strM.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: str.count))
            
            for result in results.reversed(){
                
                let range = result.range(at: 0)
                //给目标字符串添加颜色
                //给特殊的文本添加点击事件 使用YYText
                let highlight = YYTextHighlight()
                //高亮时文字的颜色
                highlight.setColor(UIColor.lightGray)
               
                //把"高亮"属性设置到某个文本范围
                strM.yy_setTextHighlight(range, color: ConstFile.status_high_color, backgroundColor: nil) { (view, attr, range, rect) in
                    // 通知的方式发送 range 到各自的控制器里 去匹配原始的range
                    
                }
                // 如果是匹配链接 那么直匹配到时第一个就可以了 比如很多新闻类内容 标题和链接名字一样
                if item != ConstFile.reg_string_url
                   && item != ConstFile.reg_all_text
                   && item != ConstFile.reg_string_emj
                   && item != ConstFile.reg_string_user
                   && item != ConstFile.reg_string_huati
                   && item != "普通网页" {
                     break;
                }
                
                if (item == ConstFile.reg_string_user){
                    
                    let linkStr = (str as NSString).substring(with: range)
                    strM.addAttribute(NSAttributedString.Key.link, value: linkStr, range: range)
                    strM.addAttribute(NSAttributedString.Key.underlineColor, value: ConstFile.gloab_bg_color , range: range)
                }
                
            }
        }
    }
    
    
    /// 给特殊文本添加高亮  参数:1.设置查找规则(正则表达式) 2.一个有string转换的富文本对象
    static func addHighlighted(regex:NSRegularExpression,strM:NSMutableAttributedString){
        let str = strM.string
        //2.通过规则在字符串中查找目标字符串
        let results = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
        strM.addAttribute(NSAttributedString.Key.font, value: ConstFile.status_text_font, range: NSRange(location: 0, length: str.count))
        for result in results{
            let range = result.range(at: 0)
            //给目标字符串添加颜色
            strM.addAttributes([NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)], range: range)
            
            //给特殊的文本添加点击事件 使用YYText
//            let border = YYTextBorder(fill: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), cornerRadius: 3)
            let highlight = YYTextHighlight()
//            //高亮时文字的颜色
            highlight.setColor(UIColor.lightGray)
//            highlight.setBackgroundBorder(border)
            //把"高亮"属性设置到某个文本范围
//            strM.yy_setTextHighlight(highlight, range: range)
            strM.yy_setTextHighlight(range, color: UIColor.red, backgroundColor: nil) { (view, attr, range, rect) in
                
                
            }
            
        }
    }
    
    /// 赋值视频 链接等信息给富文本
    static func setupAttributestring(m: StatusModel, attributeString: NSMutableAttributedString)
    ->([String],NSMutableAttributedString,ObjectModel?){
        
        var videoModel:ObjectModel?
        // 替换链接 视频或网页链接
        var txt = ["(\\...全文)"]
        if m.linkArray != nil {
            for item in (m.linkArray)! {
                let range = item.keys.first!
                
                if item.values.first!.annotations != nil && item.values.first!.annotations!.count > 0 {
                    MTLog(msg:"转发主cell range: \(range) -- str: \(attributeString.string)")
                    let obj = item.values.first!.annotations!.first!
                    if (obj.object_type.elementsEqual("video")
                        || obj.object_type.elementsEqual("audio")
                        || obj.object_type.elementsEqual("story"))
                        && obj.object.display_name != nil {
                        
                        let subStr = "[视频]" + obj.object.display_name!
                        
                        attributeString.replaceCharacters(in: range, with: subStr)
                        videoModel = item.values.first!.annotations!.first!.object
                       
                    }else if item.values.first!.annotations!.first!.object_type.elementsEqual("place"){
                        let subStr = "[定位]" + (obj.object.display_name ?? "普通网页")
                        attributeString.replaceCharacters(in: range, with: subStr)
                        
                    }
                    else if item.values.first!.annotations!.first!.object_type.elementsEqual("article"){
                        let subStr = "[头条]" + (obj.object.display_name ?? "普通网页")
                        attributeString.replaceCharacters(in: range, with: subStr)
                       
                    }
                    else {
                        let subStr = " [网址] " + (obj.object.display_name ?? "普通网页")
                        
                        attributeString.replaceCharacters(in: range, with: subStr)
                       
                    }
                    // 将要高亮显示的文本链接加入正则数组
                    var name = (obj.object.display_name ?? "普通网页")
                    name = name.replacingOccurrences(of: "(", with: "\\(")
                    name = name.replacingOccurrences(of: ")", with: "\\)")
                    txt.append(name)
                    
                } else// 目前非短连接都直接显示为普通网页
                {
                    MTLog(msg:"转发主cell网页 range: \(range) -- str: \(attributeString.string)")
                    attributeString.replaceCharacters(in: range, with: " [网址]普通网页")
                    txt.append("普通网页")
                    
                }
                
            }
        }
        
        return (txt, attributeString, videoModel)
    }

   
    
}
