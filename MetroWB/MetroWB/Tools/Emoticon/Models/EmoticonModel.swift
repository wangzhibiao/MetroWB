//
//  EmoticonModel.swift
//  Swift图文混排
//
//  Created by 王小帅 on 2016/12/26.
//  Copyright © 2016年 王小帅. All rights reserved.
//

import UIKit
import YYModel
import HandyJSON
import SwiftyJSON
import Material

/// 表情模型
class EmoticonModel: HandyJSON {

    /// 表情简体中文名字 发送给服务器的
    var chs: String?
    /// 表情的本地路径 供本地图文混排用
    var png: String?
    /// 表情的类型  false - 图片  | true - emoji 的十六进制编码
    var type = false
    /// emoji的十六进制编码
    var code: String?
    
    /// 表情等父目录
    var dir:String?
    
    /// 表情等图片
    var image:UIImage?{
        
        // 判断类型
        if type {
            return nil
        }
        
        // 设置目录等时候去设置图片
        guard  let dir = dir,
            let png = png,
            let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil),
            let bundle = Bundle(path: path)
            
            else {
                return nil
        }
        
        // 区分普通表情和视屏链接等
        if png == "timeline_card_small_video.png" {
            return Icon.cm.videocam
        }else if png == "timeline_card_small_web.png" {
            return Icon.cm.menu
        }else if png == "timeline_icon_photo.png" {
            return Icon.cm.photoLibrary
        }else if png == "compose_locatebutton_succeeded.png" {
            return Icon.place
        }else if png == "timeline_card_small_article.png" {
            return Icon.cm.menu
        }else {
            return UIImage(named: "\(dir)/\(png)", in: bundle, compatibleWith: nil)
        }
        
    }

    
    /// 获取表情等属性文本
    func imgTxt(font: UIFont) -> NSAttributedString {
        
        // 判断是否有图片
        guard let image = image else {
            return NSAttributedString(string: " ")
        }
        
        // 文本附件
//        let img = UIImageView(image: image)
//        img.contentMode = .scaleAspectFit
        let attachment = NSTextAttachment()
        attachment.image = image
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -6, width: height, height: height)
        
        // 区分一下 是表情还是 视频 网址e等连接图片
        return NSAttributedString(attachment: attachment)
//        if image.size.height > height {
//            return NSMutableAttributedString.yy_attachmentString(withContent: image, contentMode: .scaleAspectFit, attachmentSize: CGSize(width: height, height: height), alignTo: font, alignment: .center)
//        }else {
////            return NSMutableAttributedString.yy_attachmentString(withContent: image, contentMode: .center, attachmentSize: CGSize(width: height, height: height), alignTo: font, alignment: .center)
//            return NSAttributedString(attachment: attachment)
//        }
    }

    
    required init(){}
}
