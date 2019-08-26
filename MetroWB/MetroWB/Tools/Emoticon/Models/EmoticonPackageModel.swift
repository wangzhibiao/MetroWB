//
//  EmoticonPackageModel.swift
//  Swift图文混排
//
//  Created by 王小帅 on 2016/12/26.
//  Copyright © 2016年 王小帅. All rights reserved.
//

import UIKit
import HandyJSON
import SwiftyJSON

/// 保存表情的包 模型
/// emoticins.plist 目录结构
/// |-- version
/// |-- packages : 这里才是存储表情包的数组
class EmoticonPackageModel: HandyJSON {

    /// 表情的包名路径  default
    var id: String?
    /// 组名
    var gname:String?
    
    /// 表情的空数组
    var emoticons: [EmoticonModel] {
    
        guard let id = id,
            let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil),// 根据组名加载表情包数据
            let bundle = Bundle(path: path),
            let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: id),
            let info = NSArray(contentsOfFile: infoPath),
            let models = [EmoticonModel].deserialize(from: info) //NSArray.yy_modelArray(with: EmoticonModel.self, json: info) as? [EmoticonModel]
            else {
                return [EmoticonModel]()
        }
        
        // 循环赋值 父目录
        for m in models{
            m!.dir = id
        }
        
        // 赋值属性
        return models as! [EmoticonModel]
        
    }
    
    required init(){}
}
