//
//  String+Extension.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/27.
//

import Foundation

// MARK: - 扩展string类  增加拼接沙盒路径属性
extension String {
    
    // 虽然不能分类不能写属性 但是可写计算型属性
    var documentUrl: String {
        
        // 获取磁盘文档目录
        let doct = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        
        return (doct as NSString).appendingPathComponent(self)
    }
    
    
    /// 根据传入的正则表达式 筛选出目标字符串
    ///
    /// - Returns: 目标字符串元祖对象
//    func getSource() -> (linker: String, source: String)? {
//        
//        let pattern = "<a href=\"(.*?)\" .*?>(.*?)</a>"
//        guard let reg = try? NSRegularExpression(pattern: pattern, options: []),
//            let result = reg.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count))
//            else {
//                return nil
//        }
//        
//        let lik = (self as NSString).substring(with: result.rangeAt(1))
//        let src = (self as NSString).substring(with: result.rangeAt(2))
//        
//        return (lik, src)
//    }
}
