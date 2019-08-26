//
//  EmoticonTools.swift
//  Swift图文混排
//
//  Created by 王小帅 on 2016/12/26.
//  Copyright © 2016年 王小帅. All rights reserved.
//

import Foundation
import UIKit

/// 表情管理工具
class EmoticonTools {
    
    // 懒加载一个表情包的模型
    lazy var packages = [EmoticonPackageModel]()
    
    // 单利
    static let shared = EmoticonTools()
    
    // 私有化初始化方法 职能通过单利访问
    private init (){
        // 加载本地表情包
        loadBundle()
    }
}


// MARK: - 检索表情
extension EmoticonTools {

    /// 根据表情名字检索表情
    ///
    /// - Parameter emName: 表情名字 格式 [爱你]
    /// - Returns: 表情模型可选
    func findEmoction(emName: String) -> EmoticonModel? {
        
        // 从所有的包中去检索
        for p in packages {
            
            let result = p.emoticons.filter({ (em) -> Bool in
                return em.chs == emName
            })
            // 如果检索到了就返回
            if result.count == 1 {
                return result[0]
            }
        }
        
        return nil
    }
    
    
    /// 将普通文本转换为图文混排的属性文本
    ///
    /// - Parameter str: 普通文本
    /// - Returns: 属性文本
    func emoctionString(str: String, font: UIFont) -> NSAttributedString {
        
        // 转换属性文本 注意 要替换文字 所以定义成可变的字符串
        let attrStr = NSMutableAttributedString(string: str)
        
        // 正则检索文本的中的表情属性 做替换
        let pattern = "\\[.*?\\]"
        guard let rgex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return attrStr
        }
        
        // 全部匹配
        let matchs = rgex.matches(in: str, options: [], range: NSRange(location: 0, length: attrStr.length))
        
        // 遍历匹配结果 做文本替换 要做替换倒叙保证range的正确性
        for m in matchs.reversed() {
            
            // 获取匹配到字段的range
            let r = m.range(at: 0)
            
            // 获取匹配到的图像文字
            let imgStr = (str as NSString).substring(with: r)
            
            // 根据名字获取图片
            guard let img = findEmoction(emName: imgStr) else {
                return attrStr
            }
            
            // 将图片文本替换
            attrStr.replaceCharacters(in: r, with: img.imgTxt(font: font))
            
        }
        
        // 统一设置文字属性
        attrStr.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: attrStr.length))
        
        
        return attrStr
    }
}


// MARK: - 获取表情包
extension EmoticonTools {

    
    /// 加载本地表情包
    func loadBundle() {
        
        // 获取bundle路径
        guard let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil),
            // 自定义bundle
            let bundle = Bundle(path: path),
            // 加载bundle下的Emoticons.plist
            // 只需要里面的  packages 数组
            let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
            let em = NSArray(contentsOfFile: plistPath),
            let models = [EmoticonPackageModel].deserialize(from: em)//NSArray.yy_modelArray(with: EmoticonPackageModel.self, json: em) as? [EmoticonPackageModel]
        
            else{
                return
        }
        
        for m in models {
            packages.append(m!)
        }
        
//        packages += models
    }
}
