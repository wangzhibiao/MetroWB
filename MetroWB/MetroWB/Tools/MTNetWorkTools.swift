//
//  MTNetWorkTools.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/23.
//

import UIKit
import Alamofire
import SwiftyJSON

enum netStatus {
    case none
    case wifi
    case wps
    case badnet
    
}

/// 网络请求工具类
class MTNetWorkTools: NSObject {

    // 单例
    public static let shared = MTNetWorkTools()
    private override init(){}
    
    // 用户授权管理对象
    lazy var userAccess = UserModel.getUserAccess()
    
    // 当前l网络状态
    var statusStr: netStatus = .none
    
    // 请求管理对象
    private static let sharedSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        return Alamofire.SessionManager(configuration: configuration)
    }()
   
    // 定义成功 失败 网络不好的 三个callback
    typealias SuccessCallBack = (_ JSON : String)->()
    typealias FailerCallBack = (_ Error_msg : String)->()
//    typealias BadNetWorkCallBack = (_ Error : Error)->()
    
   
}

// 获取用户信息
extension MTNetWorkTools {
    
    /// 获取用户信息
    func UserInfo(uid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.UserInfoUrl
        
        let parameters = ["uid": uid]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取用户的粉丝 关注 微博数量
    func UserCountInfo(uid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.UserCountsUrl
        
        let parameters = ["uids": [uid]]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 用户粉丝s列表
    func UserFansList(uid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.FansUrl
        
        let parameters = ["uid": uid]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 用户关注列表
    func UserFollowList(uid: String,cursor:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.FriednsUrl
        
        let parameters = ["uid": uid, "cursor":cursor] as [String : Any]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取未读消息
    func UnreadCountRequset(uid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.UnreadUrl
        
        let parameters = ["uid": uid]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    
}

/// 短连接转换以及获取信息
extension MTNetWorkTools {
    
    /// 长链接转短连接
    func LongToShortRequest(longUrl:String,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let detialUrl = ConstFile.LongToShortUrl
        
        let parameters = ["url_long": longUrl]
        
        // 调用基础请求
        tokenRequest(url: detialUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 获取短连接详细内容
    func ShortUrlDetialRequest(shortUrl:String,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let detialUrl = ConstFile.ShortinfoUrl
        
        let parameters = ["url_short": shortUrl, "url_ssig": 1] as [String : Any]
        
        // 调用基础请求
        tokenRequest(url: detialUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
}

/// 各种写入 发微博 评论 图片 点赞 收藏等
extension MTNetWorkTools {
    
    /// 发微博
    func pushStatusRequest(status: StatusModel,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.PushStatusUrl
        
        let parameters = ["status": status.toJSONString()]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 评论一条哦微博
    func createCommentRequest(statusID: String, comment: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.CreateCommentStatusUrl
        
        let parameters = ["id": statusID,"comment": comment]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .post, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 评论一条评论
    func createReplyCommentRequest(statusID: String,comment: String,cid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.CreateReplyCommentUrl
        
        let parameters = ["id": statusID, "comment": comment, "cid": cid]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .post, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 删除一条评论
    func delCommentRequest(cid: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.DelCommentUrl
        
        let parameters = ["cid": cid]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .post, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 收藏一条微博
    func keepStatusRequest(id: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.KeepUrl
        
        let parameters = ["id": id]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .post, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 取消收藏
    func unKeepStatusRequest(id: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.UnKeepUrl
        
        let parameters = ["id": id]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .post, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
    /// 跳转到微博
    func goRequest(statusID: String,id: String,success: SuccessCallBack?, failure: FailerCallBack?){
        // 请求新浪微博数据
        let sinaUrl = ConstFile.gourl
        
        let parameters = ["uid": statusID, "id": id]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, reqMethod: .get, paramers: parameters as [String : AnyObject], success: success, failure: failure)
    }
    
}


/// 获取微博方法
extension MTNetWorkTools {
    
    /// 获取微博数据列表
    ///
    /// - Parameters:
    ///   - since_id: 默认0 有值则返回大于该值的微博即最新的
    ///   - max_id: 默认0 有值则返回小于等于该值的微博 即以前的微博
    ///   - completion: 回调
    func statusListRequest(since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let sinaUrl = ConstFile.HomeStatusUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: sinaUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取单条微博的详细信息
    func statusDetialRequest(status:StatusModel,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let detialUrl = ConstFile.StatusDetialUrl
        
        let parameters = ["id": (status.id as NSNumber),"uid": (status.user!.id as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: detialUrl, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取评论列表
    func statusCommentsRequest(status:StatusModel,since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.StatusCommentsUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["id": (status.id as NSNumber),"since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取转发列表
    func statusRepostsRequest(status:StatusModel,since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.StatusRepostsUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["id": (status.id as NSNumber),"since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取@我的微博
    func AtMeStatusRequest(since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.AtMeStatusUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取@我的评论
    func AtMeCommentRequest(since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.AtMeCommentUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取我收到评论
    func CommentToMeRequest(since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.CommentToMeUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取我发出评论
    func CommentFromMeRequest(since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.CommentFromMeUrl
        
        // 这里注意:如果maxid 有值 返回ID小于或等于max_id的微博
        // 所以会产生一条重复的数据 所以maxid要-1
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取我发出评论
    func FavoritesRequest(page:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.FavoritesUrl
        
        var parameters = [String: AnyObject]()
        if page > 0 {
            parameters = ["page": (page as NSNumber)]
        }
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    /// 获取我发出的微博列表
    func StatusByMeRequest(user:UserModel,since_id:Int64 = 0, max_id:Int64 = 0,success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.UserTimelineUrl
        let maxID = max_id > 0 ? (max_id - 1) : 0
        let parameters = ["uid": user.id,"since_id": (since_id as NSNumber), "max_id": (maxID as NSNumber)] as [String : Any]
        
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject], success: success, failure: failure)
        
    }
    
    
    /// 热门相关
    func HotRequest(success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.HotTimelineUrl
         let parameters = ["source": ConstFile.sina_app_key]
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject] , success: success, failure: failure)
        
    }
    
    func HotRequest1(success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 请求新浪微博数据
        let Url = ConstFile.HotUrl
        
        let parameters = ["source": ConstFile.sina_app_key]
        // 调用基础请求
        tokenRequest(url: Url, paramers: parameters as [String : AnyObject] , success: success, failure: failure)
        
    }
    
    
}




/// 基础请求方法
extension MTNetWorkTools {
    
    /// 该方法负责request请求，默认包含assessToken
    ///
    /// - Parameters:
    ///   - url: 请求的路径
    ///   - reqMethod: 请求方法 默认 GET
    ///   - paramers: 默认包含assessToken
    ///   - completion: 回调函数
    func tokenRequest(url: String, reqMethod: HTTPMethod = HTTPMethod.get, paramers: [String: AnyObject]?, success: SuccessCallBack?, failure: FailerCallBack?) {
        
        // 因为token是可选的（用户登录的时候还没有token），所以如果token不存在则不能继续请求网络数据
        guard userAccess.access_token != nil else {
            // 没有token，直接返回
//            failure!("token已过期，重新登录来获取授权")
            let request = WBAuthorizeRequest.request() as! WBAuthorizeRequest
            request.redirectURI = ConstFile.AouthUrl
            request.scope = "all"
            WeiboSDK.send(request)
            return
        }
        
        // 判断是否有参数，并且将token添加到参数列表
        var paramers = paramers
        if paramers == nil {
            paramers = [String: AnyObject]()
        }
        // 加入token
        paramers?["access_token"] = userAccess.access_token as AnyObject?
        
        // 调用基础请求
//        sendRequest(url: url, parmers: paramers, success: success, failure: failure)
        sendRequest(url: url, method: reqMethod, parmers: paramers, success: success, failure: failure)
        
    }
    
    /// 网络状态监听
    func currentNetReachability() {
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            
            switch status {
            case .unknown:
                self.statusStr = .none//"未识别的网络"
                break
            case .notReachable:
                self.statusStr = .badnet//"不可用的网络(未连接)"
            case .reachable:
                if (manager?.isReachableOnWWAN)! {
                    self.statusStr = .wps//"2G,3G,4G...的网络"
                } else if (manager?.isReachableOnEthernetOrWiFi)! {
                    self.statusStr = .wifi//"wifi的网络";
                }
                break
            }
        }
        manager?.startListening()
    }
    
    // 基础请求方法
    private func sendRequest(url: String, method: HTTPMethod? = .get, parmers: [String : AnyObject]?, success: SuccessCallBack?, failure: FailerCallBack?){
        
        MTNetWorkTools.sharedSessionManager.request(url, method: method!, parameters: parmers).responseString {(resp) in
            
            // 判断请求状态，做相应处理
            switch resp.result {
                
            case .success(let json):
                
                var dict = JSON(parseJSON: json).dictionaryObject
                
                if let error = dict?["error_code"] as? Int64 {
                   if let msg = ConstFile.errorInfo[error] {
                        failure!(msg)
                   }else {
                    failure!("未知错误")
                    }
                    
                }else {
                    success!(json)
                    MTLog(msg:"JSON: \(json)")
                }
                
            case .failure(let error):
                
                if error._code == NSURLErrorTimedOut {
                    failure!("请求超时")
                }else if error._code == NSURLErrorCannotFindHost || error._code ==  NSURLErrorCannotFindHost {
                    failure!("无法找到指定域名服务器")
                }else if error._code == NSURLErrorNetworkConnectionLost || error._code == NSURLErrorNotConnectedToInternet {
                    failure!("无法连接到网络")
                }else {
                    failure!(error.localizedDescription)
                }
                
            }
        }
    }
    
}



