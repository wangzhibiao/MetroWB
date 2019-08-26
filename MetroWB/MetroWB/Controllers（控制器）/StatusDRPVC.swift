//
//  StatusDRPVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/20.
//

import UIKit
import Pageboy

/// 微博详情 评论 转发的 主控制器
class StatusDRPVC: BaseViewController {
    
    // 微博模型
    var model: StatusModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置导航栏左侧视图
        self.setLeftBarItem(title: "微博详情", icon: MTNetWorkTools.shared.userAccess.avatar_large)
    }
    
    // 默认控制器
    override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        
        return .next
    }
    
    // 加载数据
    override func setItemsAndTitlesData() {
        
        // 转发微博
        let detialVC = StatusDetialVC_ASDK()
        detialVC.statusModel = model
//        detialVC.setupTableInset(top: 0)
        // 转发的评论
        let commentVC = StatusCommentVC_ASDK()
        commentVC.statusModel = model
//        commentVC.setupTableInset(top: 60)
        
        // 带转发的
        if self.model?.retweeted_status != nil {
            
            // 原文
            let detialVCorg = StatusDetialVC_ASDK()
            detialVCorg.statusModel = self.model!.retweeted_status!
//            detialVCorg.setupTableInset(top: 0)
            // 原文评论
            let commentVCorg = StatusCommentVC_ASDK()
            commentVCorg.statusModel = self.model!.retweeted_status!
//            commentVCorg.setupTableInset(top: 0)
            
            self.items = [detialVC, commentVC, detialVCorg, commentVCorg]
            self.titles = ["  正文"," 评论","原文","原文评论"]
        }else {// 原创的
            self.items = [detialVC, commentVC]
            self.titles = ["  正文"," 评论"]
        }
        
    }
    
  
}

