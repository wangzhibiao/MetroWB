//
//  CommentVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/30.
//

import UIKit

class CommentVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置导航栏左侧视图
        self.setLeftBarItem(title: "消息(评论)", icon: MTNetWorkTools.shared.userAccess.avatar_large)
    }
    

    // 重写标题方法 返回具体控制器个数
    override func setItemsAndTitlesData() {
        items = [CommentToMeVC_ASDK(), CommentFromMeVC_ASDK()]
        titles = ["  我收到的评论","  我发出的评论"]
    }

    

}
