//
//  UserModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/27.
//

import UIKit
import HandyJSON

/// 用户模型
class UserModel: NSObject,HandyJSON {

    var id:Int64  = 0//    用户UID
    var idstr: String? //    字符串型的用户UID
    var screen_name:String?//    用户昵称
    var name:String?//    友好显示名称
    var verified_type:Int = 0 //    暂未支持
    var avatar_large:String? //    用户头像地址（大图），180×180像素
    var mbrank:Int = 0 // vip认证等级
    var profile_image_url:String?//用户头像地址（中图），50×50像素
    var province:Int64?//    int    用户所在省级ID
    var city:Int64?   // int    用户所在城市ID
    var location:String?    //string    用户所在地
    var desc:String?    //string    用户个人描述
    var url:String?    //string    用户博客地址
    var profile_url:String!   // string    用户的微博统一URL地址
    var domain:String?    //string    用户的个性化域名
    var weihao:String?    //string    用户的微号
    var gender:String!    //string    性别，m：男、f：女、n：未知
    var followers_count:Int64!  //  int    粉丝数
    var friends_count:Int64!    //int    关注数
    var statuses_count:Int64!    //int    微博数
    var favourites_count:Int64!    //int    收藏数
    var created_at:String!    //string    用户创建（注册）时间
    var following:Bool!    //boolean    暂未支持
    var allow_all_act_msg:Bool?    //boolean    是否允许所有人给我发私信，true：是，false：否
    var geo_enabled:Bool?    //boolean    是否允许标识用户的地理位置，true：是，false：否
    var verified:Bool!    //boolean    是否是微博认证用户，即加V用户，true：是，false：否
    var avatar_hd:String?    //string    用户头像地址（高清），高清头像原图
    var verified_reason:String?    //string    认证原因
    var follow_me:Bool!    //boolean    该用户是否关注当前登录用户，true：是，false：否
    var online_status:Int64?    //int    用户的在线状态，0：不在线、1：在线
    var bi_followers_count:Int64!    //int    用户的互粉数
    //lang    //string    用户当前的语言版本，zh-cn：简体中文，zh-tw：繁体中文，en：英语
    var remark:String?   // string    用户备注信息，只有在查询用户关系时才返回此字段
//    var status:    //object    用户的最近一条微博信息字段 详细
    var allow_all_comment:Bool?    //boolean    是否允许所有人对我的微博进行评论，true：是，false：否
    
    
    // 性别字符串
    var genderStr:String {
        
        var str = "未知"
        if self.gender == "m" {
            str = "男"
        }
        
        if self.gender == "f" {
            str = "女"
        }
        return str
    }
    
    
    required override init(){}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.desc <-- "description"
    }
    
    
    
    // 文件名字
    let accessFile = "userAccess.josn"
    // 请求令牌
    var access_token: String?// = "2.00TbIoYCguvGXBc535157ec15qYhrC"

    // 过期的秒数
    var expires_in: TimeInterval = 0 {
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    // 应为expires_in 是秒数，所以要定义一个date表示具体的过期时间
    // 并且在expires_in被设置的时候 自动设置它
    var expiresDate: Date?
    
    // 沙盒获取
    class func getUserAccess()-> UserModel{
        // 从沙河读取数据
        let filePath = UserModel().accessFile.documentUrl
        guard let data = NSData(contentsOfFile: filePath),
            // 使用yymodel 需要一个json的字典
            let dict = try? JSONSerialization.jsonObject(with: data as Data, options: [])
            else {
                return UserModel()
        }
        
        // 赋值给self
        let ua = UserModel.deserialize(from: dict as! [String: AnyObject])
        ua!.expiresDate = Date(timeIntervalSinceNow: ua!.expires_in)
        // 测试过期
        //        tempUA.expiresDate = Date(timeIntervalSinceNow: (-360 * 24))
        
        // 判断是否过期
       
        if ua!.expiresDate?.compare(Date()) != ComparisonResult.orderedDescending {
            // 清空self
            ua!.access_token = nil
            ua!.id = 0
            
            ua!.saveUserAccess()
        }
        
        return ua!
    }
    
    
    // 存沙盒
    // 存储为json 到文档目录下
    func saveUserAccess(){
        
        // 首先注意：expiresDate是固定不变的 expires_in每次请求都是距离过期时间的秒数所以我们只存储前者
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
