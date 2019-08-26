//
//  FavoritesVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/1.
//

import UIKit
import SnapKit
import MJRefresh
import HandyJSON
import SwiftyJSON
import AsyncDisplayKit

/// 收藏微博列表控制器
class FavoritesVC_ASDK: BaseChildVC_ASDK {
    

    // 当前page
    var currentPage:Int64 = 1
    // 当前显示视频的cell
    var optionIndexPath:IndexPath?
    
    // 微博数组
    lazy var statusModelArray:[FavoritesModel] = [FavoritesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func setupTableInset() {
//         node.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: ConstFile.bottomToolBarHeight, right: 0)
//    }
}

// 加载数据
extension FavoritesVC_ASDK {
    
    override func loadData(){
        
        self.currentPage = 1
        MTNetWorkTools.shared.FavoritesRequest(success: { (json) in
            let dict = JSON(parseJSON: json)
            guard let statusModels = [FavoritesModel].deserialize(from: dict["favorites"].rawString()!) else {
                MTAlertView().showInfo(msg: "加载失败...", inview: self.node.view, duration: 2)
                return
            }
            
            // 将模型中的url 筛选出来放进链接数组
            let group = DispatchGroup()
            let setUrlQuen = DispatchQueue(label: "setUrlQuen")
            
            for item in statusModels {
                
                // 原创
                group.enter()
                setUrlQuen.sync(execute: {
                    
                    let attr = NSMutableAttributedString(string: item!.status.textString)
                    RichTxtTool.resetLink(strM: attr) { (urlArray) in
                        if let array = urlArray {
                            item?.status.linkArray = array
                            
                            // 判断是否包含视频
                            for dict in array {
                                if dict.values.first!.annotations != nil
                                    && dict.values.first!.annotations!.count > 0
                                    && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                    
                                    let obj = dict.values.first!.annotations!.first!.object!
                                    
                                    
                                    if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                        
                                    else {
                                        item?.status.isContentVideo = false
                                        
                                    }
                                }
                            }
                        }
                        group.leave()
                    }
                })
                
                // 区分是否转发微博
                if item?.status.retweeted_status != nil { // 转发
                    group.enter()
                    setUrlQuen.sync(execute: {
                        
                        let str = "@" + item!.status.retweeted_status!.user!.screen_name! + ": " + item!.status.retweeted_status!.textString
                        
                        let attr = NSMutableAttributedString(string: str)
                        RichTxtTool.resetLink(strM: attr) { (urlArray) in
                            if let array = urlArray {
                                item?.status.retweeted_status?.linkArray = array
                                
                                // 判断是否包含视频
                                for dict in array {
                                    if dict.values.first!.annotations != nil
                                        && dict.values.first!.annotations!.count > 0
                                        && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                        
                                        let obj = dict.values.first!.annotations!.first!.object!
                                        
                                        if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.image != nil && obj.slide_cover != nil
                                            && obj.slide_cover?.slide_videos != nil {
                                            
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.urls != nil
                                            && obj.urls?.hevc_mp4_hd != nil {
                                            
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        
                                       else {
                                            item?.status.retweeted_status?.isContentVideo = false
                                            
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
                
                let temp = (statusModels as! [FavoritesModel]) + self.statusModelArray
                self.statusModelArray = temp
                self.node.view.mj_header.endRefreshing()
                self.node.reloadData()
            })
            
            
        }) { (err_msg) in

             MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }
    
    override func loadMore(){
        
        self.currentPage += 1
        MTNetWorkTools.shared.FavoritesRequest( page: currentPage,success: { (json) in
            let dict = JSON(parseJSON: json)
            guard let statusModels = [FavoritesModel].deserialize(from: dict["favorites"].rawString()!) else {
                
                MTAlertView().showInfo(msg: "加载失败...", inview: self.node.view, duration: 2)
                return
            }
            
            // 将模型中的url 筛选出来放进链接数组
            let group = DispatchGroup()
            let setUrlQuen = DispatchQueue(label: "setUrlQuen")
            
            for item in statusModels {
                
                // 原创
                group.enter()
                setUrlQuen.sync(execute: {
                    
                    let attr = NSMutableAttributedString(string: item!.status.textString)
                    RichTxtTool.resetLink(strM: attr) { (urlArray) in
                        if let array = urlArray {
                            item?.status.linkArray = array
                            
                            // 判断是否包含视频
                            for dict in array {
                                if dict.values.first!.annotations != nil
                                    && dict.values.first!.annotations!.count > 0
                                    && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                    
                                    let obj = dict.values.first!.annotations!.first!.object!
                                    
                                    if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.status.isContentVideo = true
                                        item?.status.isVeritical = (obj.image!.height > obj.image!.width)
                                    }
                                    
                                   else {
                                        item?.status.isContentVideo = false
                                        
                                    }
                                }
                            }
                        }
                        group.leave()
                    }
                })
                
                // 区分是否转发微博
                if item?.status.retweeted_status != nil { // 转发
                    group.enter()
                    setUrlQuen.sync(execute: {
                        
                        let str = "@" + item!.status.retweeted_status!.user!.screen_name! + ": " + item!.status.retweeted_status!.textString
                        
                        let attr = NSMutableAttributedString(string: str)
                        RichTxtTool.resetLink(strM: attr) { (urlArray) in
                            if let array = urlArray {
                                item?.status.retweeted_status?.linkArray = array
                                
                                // 判断是否包含视频
                                for dict in array {
                                    if dict.values.first!.annotations != nil
                                        && dict.values.first!.annotations!.count > 0
                                        && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story") {
                                        
                                        let obj = dict.values.first!.annotations!.first!.object!
                                        
                                        if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.image != nil && obj.slide_cover != nil
                                            && obj.slide_cover?.slide_videos != nil {
                                            
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        else if obj.urls != nil
                                            && obj.urls?.hevc_mp4_hd != nil {
                                            
                                            item?.status.retweeted_status?.isVeritical = (obj.image!.height > obj.image!.width)
                                            item?.status.retweeted_status?.isContentVideo = true
                                        }
                                        
                                        else {
                                            item?.status.retweeted_status?.isContentVideo = false
                                            
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
                
                let indexp = IndexPath(row: self.statusModelArray.count-1, section: 0)
                let temp = self.statusModelArray + (statusModels as! [FavoritesModel])
                self.statusModelArray = temp
                self.node.view.mj_footer.endRefreshing()
                self.node.reloadData()
                
                self.node.scrollToRow(at: indexp, at: .bottom, animated: false)
                
            })
            
        }) { (err_msg) in
            
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
    }
}


// 数据源和代理方法
extension FavoritesVC_ASDK {
    
    // 行数
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.statusModelArray.count
    }
    
    // cell
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let m = self.statusModelArray[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = StatusCell_ASDK(model: m.status!, inx: indexPath)
            return cell
        }
        return nodeBlock

    }
    
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let drpVC = StatusDRPVC()
        drpVC.model = self.statusModelArray[indexPath.row].status
        self.navigationController?.pushViewController(drpVC, animated: false)
    }
   
    
}
