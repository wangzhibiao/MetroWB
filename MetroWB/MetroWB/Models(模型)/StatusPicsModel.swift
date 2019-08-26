//
//  StatusPicsModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/27.
//

import UIKit
import HandyJSON

/// 微博配图模型
class StatusPicsModel: HandyJSON {
    /// 配图地址
    var thumbnail_pic:String?
    var bmiddle_pic:String?    //中等尺寸图片地址，没有时不返回此字段
    var original_pic:String? // 原始图
    
    // 缩略图不清晰 这里使用h中图
    var middlePic:String? {
        return thumbnail_pic!.replacingOccurrences(of: "thumbnail", with: "bmiddle")
    }
    // 点击图片查看原图
    var originalPic:String?{
        return thumbnail_pic!.replacingOccurrences(of: "thumbnail", with: "large")
    }
    
    required init(){}
    
}
