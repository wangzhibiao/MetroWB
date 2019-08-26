//
//  AtMeVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/30.
//

import UIKit

/// @我的评论和微博控制器
class AtMeVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置导航栏左侧视图
        self.setLeftBarItem(title: "消息(@我的)", icon: MTNetWorkTools.shared.userAccess.avatar_large)
    }
    
    // 重写标题方法 返回具体控制器个数
    override func setItemsAndTitlesData() {
        items = [ATMEStatusVC_ASDK(), ATMECommentVC_ASDK()]
        titles = ["  @我的微博","  @我的评论"]
    }
}
