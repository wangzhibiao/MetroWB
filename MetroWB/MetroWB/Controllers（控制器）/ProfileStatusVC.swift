//
//  ProfileStatusVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//


import UIKit
import SnapKit
import MJRefresh
import HandyJSON
import SwiftyJSON
import AsyncDisplayKit

/// 个人界面微博控制器
class ProfileStatusVC: BaseChildVC_ASDK {
    
    
    // 当前显示视频的cell
    var optionIndexPath:IndexPath?
    // 用户
    var userModel:UserModel?
    // 微博数组
    lazy var statusModelArray:[StatusModel] = [StatusModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


// 加载数据
extension ProfileStatusVC {
    
    override func loadData(){
        
        MTNetWorkTools.shared.StatusByMeRequest(user: self.userModel!, success: { (json) in
            let dict = JSON(parseJSON: json)
            guard let statusModels = [StatusModel].deserialize(from: dict["statuses"].rawString()!) else {
                return
            }
            
            // 将模型中的url 筛选出来放进链接数组
            let group = DispatchGroup()
            let setUrlQuen = DispatchQueue(label: "setUrlQuen")
            
            for item in statusModels {
                
                // 原创
                group.enter()
                setUrlQuen.sync(execute: {
                    
                    let attr = NSMutableAttributedString(string: item!.textString)
                    RichTxtTool.resetLink(strM: attr) { (urlArray) in
                        if let array = urlArray {
                            item?.linkArray = array
                            
                            // 判断是否包含视频
                            for dict in array {
                                if dict.values.first!.annotations != nil
                                    && dict.values.first!.annotations!.count > 0
                                    && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                    
                                    let obj = dict.values.first!.annotations!.first!.object!
                                    
                                    if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else {
                                        item?.isContentVideo = false
                                    }
                                }
                            }
                        }
                        group.leave()
                    }
                })
                
                // 区分是否转发微博
                if item?.retweeted_status != nil { // 转发
                    group.enter()
                    setUrlQuen.sync(execute: {
                        
                        let str = "@" + item!.retweeted_status!.user!.screen_name! + ": " + item!.retweeted_status!.textString
                        
                        let attr = NSMutableAttributedString(string: str)
                        RichTxtTool.resetLink(strM: attr) { (urlArray) in
                            if let array = urlArray {
                                item?.retweeted_status?.linkArray = array
                                
                                // 判断是否包含视频
                                for dict in array {
                                    if dict.values.first!.annotations != nil
                                        && dict.values.first!.annotations!.count > 0
                                        && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                        
                                        let obj = dict.values.first!.annotations!.first!.object!
                                        
                                        if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.image != nil && obj.slide_cover != nil
                                            && obj.slide_cover?.slide_videos != nil {
                                            
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.urls != nil
                                            && obj.urls?.hevc_mp4_hd != nil {
                                            
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        
                                       else {
                                            item?.retweeted_status?.isContentVideo = false
                                        }
                                    }
                                }
                            }
                            group.leave()
                        }
                    })
                }
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                
                let temp = (statusModels as! [StatusModel]) + self.statusModelArray
                self.statusModelArray = temp
                self.node.reloadData()
                self.node.view.mj_header.endRefreshing()
            })
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: self.node.view, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
        
    }
    
    override func loadMore(){
        
        var someid:Int64 = 0
        if self.statusModelArray.count > 0 {
            someid = self.statusModelArray.first!.id
        }
        
        MTNetWorkTools.shared.StatusByMeRequest(user: self.userModel!, since_id: someid, success: { (json) in
            let dict = JSON(parseJSON: json)
            guard let statusModels = [StatusModel].deserialize(from: dict["statuses"].rawString()!) else {
                return
            }
            
            // 将模型中的url 筛选出来放进链接数组
            let group = DispatchGroup()
            let setUrlQuen = DispatchQueue(label: "setUrlQuen")
            
            for item in statusModels {
                
                // 原创
                group.enter()
                setUrlQuen.sync(execute: {
                    
                    let attr = NSMutableAttributedString(string: item!.textString)
                    RichTxtTool.resetLink(strM: attr) { (urlArray) in
                        if let array = urlArray {
                            item?.linkArray = array
                            
                            // 判断是否包含视频
                            for dict in array {
                                if dict.values.first!.annotations != nil
                                    && dict.values.first!.annotations!.count > 0
                                    && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                    
                                    let obj = dict.values.first!.annotations!.first!.object!
                                    
                                    if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    
                                   else {
                                        item?.isContentVideo = false
                                    }
                                }
                            }
                        }
                        group.leave()
                    }
                })
                
                // 区分是否转发微博
                if item?.retweeted_status != nil { // 转发
                    group.enter()
                    setUrlQuen.sync(execute: {
                        
                        let str = "@" + item!.retweeted_status!.user!.screen_name! + ": " + item!.retweeted_status!.textString
                        
                        let attr = NSMutableAttributedString(string: str)
                        RichTxtTool.resetLink(strM: attr) { (urlArray) in
                            if let array = urlArray {
                                item?.retweeted_status?.linkArray = array
                                
                                // 判断是否包含视频
                                for dict in array {
                                    if dict.values.first!.annotations != nil
                                        && dict.values.first!.annotations!.count > 0
                                        && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                        
                                        let obj = dict.values.first!.annotations!.first!.object!
                                        
                                        if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.image != nil && obj.slide_cover != nil
                                            && obj.slide_cover?.slide_videos != nil {
                                            
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.urls != nil
                                            && obj.urls?.hevc_mp4_hd != nil {
                                            
                                            item?.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.retweeted_status?.isContentVideo = true
                                        }
                                        
                                        else {
                                            item?.retweeted_status?.isContentVideo = false
                                        }
                                    }
                                }
                            }
                            group.leave()
                        }
                    })
                }
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                
                let temp = self.statusModelArray + (statusModels as! [StatusModel])
                self.statusModelArray = temp
                self.node.reloadData()
                self.node.view.mj_footer.endRefreshing()
                
            })
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: self.node.view, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
        
    }
}


// 数据源和代理方法
extension ProfileStatusVC {
    
    // 行数
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
         return self.statusModelArray.count
    }
    
    // cell
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let m = self.statusModelArray[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = StatusCell_ASDK(model: m, inx: indexPath)
            return cell
        }
        return nodeBlock
        
    }
    
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let drpVC = StatusDRPVC()
        drpVC.model = self.statusModelArray[indexPath.row]
        self.navigationController?.pushViewController(drpVC, animated: false)
    }
    
}
