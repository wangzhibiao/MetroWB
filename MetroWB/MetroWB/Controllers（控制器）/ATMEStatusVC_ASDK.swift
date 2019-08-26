//
//  ATMEStatusVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import MJRefresh
import SwiftyJSON
import HandyJSON
import AsyncDisplayKit
import Material

/// @我的微博控制器
class ATMEStatusVC_ASDK: BaseChildVC_ASDK {
    
   
    // 评论列表模型
    var statusArrayModel:[StatusModel]?{
        didSet{
            guard let _ = statusArrayModel else { return }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

/// 加载数据方法
extension ATMEStatusVC_ASDK {
    
    // 根据微博id加载评论数组
    override func loadData(){
        
        var someid:Int64 = 0
        if self.statusArrayModel != nil && self.statusArrayModel!.count > 0 {
            someid = self.statusArrayModel!.first!.id
        }
        
        MTNetWorkTools.shared.AtMeStatusRequest(since_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = [StatusModel].deserialize(from: dict["statuses"].rawString()) else {
                
                MTAlertView().showInfo(msg: "未能获取数据", inview: nil, duration: 2)
                self.node.view.mj_header.endRefreshing()
                return
            }
            
            let temp = ((result as? [StatusModel]) ?? [StatusModel]()) + (self.statusArrayModel ?? [StatusModel]())
            self.statusArrayModel = temp
            self.node.view.mj_header.endRefreshing()
            self.node.reloadData()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }
    
    override func loadMore(){
        
        var someid:Int64 = 0
        if self.statusArrayModel != nil && self.statusArrayModel!.count > 0 {
            someid = self.statusArrayModel!.last!.id
        }
        
        MTNetWorkTools.shared.AtMeStatusRequest(max_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = [StatusModel].deserialize(from: dict["statuses"].rawString()) else {
                
                MTAlertView().showInfo(msg: "未能获取数据", inview: nil, duration: 2)
                self.node.view.mj_footer.endRefreshing()
                return
            }
            
            let taginx = IndexPath(row: self.statusArrayModel!.count - 1, section: 0)
            let temp = (self.statusArrayModel ?? [StatusModel]()) + ((result as? [StatusModel]) ?? [StatusModel]())
            self.statusArrayModel = temp
            
            self.node.reloadData()
            self.node.scrollToRow(at: taginx, at: UITableView.ScrollPosition.bottom, animated: false)
            
            self.node.view.mj_footer.endRefreshing()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
    }
}

/// 代理和数据源方法
extension ATMEStatusVC_ASDK {
    
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
         return self.statusArrayModel == nil ? 0 : self.statusArrayModel!.count
    }
    
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let block: ASCellNodeBlock = {
            
            return ATMEStatusAndCmtCell_ASDK(model: (self.statusArrayModel?[indexPath.row])!)
        }
        
        return block
        
    }
   
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let drpVC = StatusDRPVC()
        drpVC.model = self.statusArrayModel?[indexPath.row]
        self.navigationController?.pushViewController(drpVC, animated: false)
    }
    
    
}
