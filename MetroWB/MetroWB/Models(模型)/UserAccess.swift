//
//  UserAccess.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/27.
//

import UIKit
import HandyJSON

/// 用户授权信息模型
class UserAccess: HandyJSON {

    // 文件名字
    let accessFile = "userAccess.josn"
    // 请求令牌
    var access_token: String?// = "2.00TbIoYCguvGXBc535157ec15qYhrC"
    // 授权用户的id
    var uid: String?
    // 过期的秒数
    var expires_in: TimeInterval = 0 {
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    // 应为expires_in 是秒数，所以要定义一个date表示具体的过期时间
    // 并且在expires_in被设置的时候 自动设置它
    var expiresDate: Date?
    
    // 用户昵称
    var screen_name: String?
    // 头像    用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    /// MARK: - 这里注意 因为其他地方判断是否登录都是靠的懒加载本类 检车accessToken是否有值 所以重写init方法等时候去磁盘取
    required  init() {
    }
    // /Users/wangxiaoshuai/Library/Developer/CoreSimulator/Devices/A045A5BB-EB65-4008-B59B-E569370F25A5/data/Containers/Data/Application/E6CC32C7-9815-4E61-8D37-2B5BAC90E84E/Documents/accessFile.josn
    
    //
    // 沙盒获取
    class func getUserAccess()-> UserAccess{
        // 从沙河读取数据
        let filePath = UserAccess().accessFile.documentUrl
        guard let data = NSData(contentsOfFile: filePath),
            // 使用yymodel 需要一个json的字典
            let dict = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            else {
                return UserAccess()
        }
        
        
        // 赋值给self
        let ua = UserAccess.deserialize(from: dict as! [String: AnyObject])
        let tempUA = UserAccess()
        tempUA.access_token = ua?.access_token
        tempUA.uid = ua?.uid
        tempUA.expires_in = ua!.expires_in
        tempUA.avatar_large = ua!.avatar_large
        tempUA.screen_name = ua!.screen_name
//        self.screen_name = ua?.screen_name
//        self.avatar_large = ua?.avatar_large
        
        // 测试过期
//        tempUA.expiresDate = Date(timeIntervalSinceNow: (-360 * 24))
        
        // 判断是否过期
        if tempUA.expiresDate?.compare(Date()) != ComparisonResult.orderedDescending {
            // 清空self
            tempUA.access_token = nil
            tempUA.uid = nil
            
            tempUA.saveUserAccess()
        }
        
        return tempUA
    }
    
    
    // 存沙盒
    // 存储为json 到文档目录下
    func saveUserAccess(){
        
        // 首先注意：expiresDate是固定不变的 expires_in每次请求都是距离过期时间的秒数所以我们只存储前者
        // 利用yymodel的方法获取data
        var jsonData = self.toJSON() //(self.yy_modelToJSONObject() as? [String: AnyObject]) ?? [:]
        // 删除expires_in
//        jsonData?.removeValue(forKey: "expires_in")
        jsonData?.removeValue(forKey: "expiresDate")
        
        // 获取沙盒文档路径
        let filePath = accessFile.documentUrl
        
        var tempStr = jsonData?.description
        
        tempStr?.removeFirst()
        tempStr?.removeLast()

        tempStr = "{" + tempStr! + "}"
        // 写入沙盒用oc的方法更简单顺手
        do{
           try tempStr!.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
//            print("UserAccess.josn 写入本地沙盒 成功 ！\(filePath)")
            MTLog(msg: "UserAccess.josn 写入本地沙盒 成功 ！\(filePath)")
        }catch{
            MTLog(msg:"UserAccess.josn 写入本地沙盒 失败 ！")
        }
    }
   
}
