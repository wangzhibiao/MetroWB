//
//  HomeViewController_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/2.
//

import UIKit
import SnapKit
import MJRefresh
import HandyJSON
import SwiftyJSON
import AsyncDisplayKit
import MobilePlayer


/// 首页
class HomeViewController_ASDK: BaseChildVC_ASDK {
    
   
    // 当前显示视频的cell
    var optionIndexPath:IndexPath?
    
    // 微博数组
    var statusModelArray:[StatusModel] = [StatusModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func setupTableInset() {
//        node.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: ConstFile.bottomToolBarHeight, right: 0)
//    }
 
    
}

// 加载数据
extension HomeViewController_ASDK {
    
    // 加载最新的
    override func loadData(){
        
        var since:Int64 = 0
        if self.statusModelArray.count > 0 {
            since = self.statusModelArray.first!.id
        }
        MTNetWorkTools.shared.statusListRequest(since_id: since, success: { (json) in
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
                                    && (dict.values.first!.annotations!.first!.object_type == "video" || dict.values.first!.annotations!.first!.object_type == "story")  {
                                    
                                    let obj = dict.values.first!.annotations!.first!.object!
                                    
                                    if obj.image != nil && obj.stream != nil && obj.stream.url != nil {
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
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
                                        
                                        if obj.image != nil && obj.stream != nil && obj.stream.url != nil{
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
                
                if statusModels.count > 0 {
                     MTAlertView().showInfo(msg: "更新了\(statusModels.count)条微博", inview: self.node.view, duration: 2, alignment: .center)
                }else {
                     MTAlertView().showInfo(msg: "暂无新动态", inview: self.node.view, duration: 2, alignment: .center)
                }
                
                let temp = (statusModels as! [StatusModel]) + self.statusModelArray
                self.statusModelArray = temp
                self.node.view.mj_header.endRefreshing()
                
                self.node.reloadData()
                
            })
            
        }) { (error_msg) in
            /*
            let path = Bundle.main.path(forResource: "test1", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            // 带throws的方法需要抛异常
            do {
                /*
                 * try 和 try! 的区别
                 * try 发生异常会跳到catch代码中
                 * try! 发生异常程序会直接crash
                 */
                let data = try Data(contentsOf: url)
                let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                let jsonArr = jsonData as! NSArray
                
                for dict in jsonArr {
                    
                    guard let statusModels = [StatusModel].deserialize(from: dict) else {
                        return
                    }
                }
            } catch let error as Error? {
                print("读取本地数据出现错误!",error)
            }*/
            
            MTAlertView().showInfo(msg: error_msg, inview: nil, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }
    
    // 加载以前的
    override func loadMore(){
        
        var maxid:Int64 = 0
        
        if  self.statusModelArray.count > 0 {
            maxid = self.statusModelArray.last!.id
        }
        MTNetWorkTools.shared.statusListRequest(max_id: maxid, success: { (json) in
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
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
                                    }
                                    else if obj.image != nil && obj.slide_cover != nil
                                        && obj.slide_cover?.slide_videos != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
                                    }
                                    else if obj.urls != nil
                                        && obj.urls?.hevc_mp4_hd != nil {
                                        
                                        item?.isContentVideo = true
                                        item?.isVeritical = (obj.image!.height ?? 0 > obj.image!.width ?? 0)
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
                
                let tagetIndx = IndexPath(row: self.statusModelArray.count - 1, section: 0)
                
                let temp =  self.statusModelArray + (statusModels as! [StatusModel])
                self.statusModelArray = temp
                self.node.view.mj_footer.endRefreshing()
                
//                self.node.reloadData()
                var indexArray = [IndexPath]()
                
                for (i,_) in statusModels.enumerated() {
                    
                    let path = IndexPath(row: i + tagetIndx.row+1, section: 0)
                    indexArray.append(path)
                }
                
                self.node.insertRows(at: indexArray, with: .none)
                self.node.scrollToRow(at: tagetIndx, at: UITableView.ScrollPosition.bottom, animated: false)
                
            })
            
        }) { (error_msg) in
            
            MTAlertView().showInfo(msg: error_msg, inview: nil, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
    }
}


// 数据源和代理方法
extension HomeViewController_ASDK {
    
    // 行数
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

        return self.statusModelArray.count
    }
    
    // cell
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let m = self.statusModelArray[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = StatusCell_ASDK(model: m, inx: indexPath)
            cell.delegate = self
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



