//
//  StatusDetialVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/5.
//


import UIKit
import HandyJSON
import SwiftyJSON
import AsyncDisplayKit

/// 详情控制器
class StatusDetialVC_ASDK: BaseChildVC_ASDK{
    
    // 当前显示视频的cell
    var optionIndexPath:IndexPath?
    // 微博id
    var statusID:Int64?
    // 微博
    var statusModel:StatusModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.node.view.mj_footer = nil
    }
    
    // 跳转到微博客户端
    func linkToWB(){
        
        let uid = (self.statusModel?.user?.id)!
        let mid = (self.statusModel?.id)!
        WeiboSDK.link(toSingleBlog: "\(uid)", blogID: "\(mid)")
    }
    
}

extension StatusDetialVC_ASDK {
    
    // 加载最新的
    override func loadData(){
        
        // 将模型中的url 筛选出来放进链接数组
        let group = DispatchGroup()
        let setUrlQuen = DispatchQueue(label: "setUrlQuen")
            
        // 原创
        group.enter()
        setUrlQuen.sync(execute: {
            
            let attr = NSMutableAttributedString(string: self.statusModel!.textString)
            RichTxtTool.resetLink(strM: attr) { (urlArray) in
                if let array = urlArray {
                    self.statusModel!.linkArray = array
                    
                    // 判断是否包含视频
                    for dict in array {
                        if dict.values.first!.annotations != nil
                            && dict.values.first!.annotations!.count > 0
                            && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story")  {
                            
                            let obj = dict.values.first!.annotations!.first!.object!
                            
                            if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                self.statusModel!.isContentVideo = true
                                self.statusModel!.isVeritical = (obj.image!.height > obj.image!.width)
                            }
                            else if obj.image != nil && obj.slide_cover != nil
                                && obj.slide_cover?.slide_videos != nil {
                                
                                self.statusModel!.isContentVideo = true
                                self.statusModel!.isVeritical = (obj.image!.height > obj.image!.width)
                            }
                            else if obj.urls != nil
                                && obj.urls?.hevc_mp4_hd != nil {
                                
                                self.statusModel!.isContentVideo = true
                                self.statusModel!.isVeritical = (obj.image!.height > obj.image!.width)
                            }
                            
                            else {
                                self.statusModel!.isContentVideo = false
                            }
                            
                        }
                    }
                }
                group.leave()
            }
        })
        
        // 区分是否转发微博
        if self.statusModel!.retweeted_status != nil { // 转发
            group.enter()
            setUrlQuen.sync(execute: {
                
                var str = ""
                if let user = self.statusModel!.retweeted_status!.user {
                    let name = user.screen_name!
                    str = "@" + name + ": "
                }
                 str += self.statusModel!.retweeted_status!.textString
                
                let attr = NSMutableAttributedString(string: str)
                RichTxtTool.resetLink(strM: attr) { (urlArray) in
                    if let array = urlArray {
                        self.statusModel!.retweeted_status?.linkArray = array
                        
                        // 判断是否包含视频
                        for dict in array {
                            if dict.values.first!.annotations != nil
                                && dict.values.first!.annotations!.count > 0
                                && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                
                                let obj = dict.values.first!.annotations!.first!.object!
                                
                                if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                    self.statusModel!.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                    self.statusModel!.retweeted_status?.isContentVideo = true
                                }
                                else if obj.image != nil && obj.slide_cover != nil
                                    && obj.slide_cover?.slide_videos != nil {
                                    
                                    self.statusModel!.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                    self.statusModel!.retweeted_status?.isContentVideo = true
                                }
                                else if obj.urls != nil
                                    && obj.urls?.hevc_mp4_hd != nil {
                                    
                                    self.statusModel!.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                    self.statusModel!.retweeted_status?.isContentVideo = true
                                }
                               else {
                                    self.statusModel!.retweeted_status?.isContentVideo = false
                                }
                                
                            }
                        }
                    }
                    group.leave()
                }
            })
        }
            
        group.notify(queue: DispatchQueue.main, execute: {
            
            self.node.view.mj_header.endRefreshing()
            self.statusID = self.statusModel?.id
            self.node.reloadData()
            
        })
        
    }
    
}


// 数据源和代理方法
extension StatusDetialVC_ASDK {
    
    // 行数
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return self.statusID == nil ? 0 : 1
    }
    
    // cell
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let m = self.statusModel!
        let nodeBlock: ASCellNodeBlock = {
            let cell = StatusCell_ASDK(model: m, inx: indexPath)
            cell.delegate = self
            return cell
        }
        
        return nodeBlock
        
    }
    
    
    // 收藏
    func keepButtonClick() {
        
        // 已经收藏的就取消收藏
        if self.statusModel!.favorited {
            MTNetWorkTools.shared.unKeepStatusRequest(id: self.statusID!.description, success: { (json) in
                MTAlertView().showInfo(msg: "已取消收藏", inview: self.node.view, duration: 1)
                self.statusModel?.favorited = false
            }) { (error) in
                MTAlertView().showInfo(msg: error, inview: nil, duration: 1)
            }
        }else {
            // 没有收藏的微博 调用收藏接口
            MTNetWorkTools.shared.keepStatusRequest(id: self.statusID!.description, success: { (json) in
                MTAlertView().showInfo(msg: "收藏成功", inview: self.node.view, duration: 1)
                self.statusModel?.favorited = true
            }) { (error) in
                MTAlertView().showInfo(msg: error, inview: nil, duration: 1)
            }
        }
        
    }
    
    // 去微博
    func linketoweiboButtonClick() {
        WeiboSDK.link(toSingleBlog: self.statusModel!.user!.idstr!, blogID: self.statusID!.description)
        
    }
    
    override func statusUserNameClick(name: String) {
        var n = name.replacingOccurrences(of: "@", with: "")
        WeiboSDK.link(toUser: n)
    }
    
}
