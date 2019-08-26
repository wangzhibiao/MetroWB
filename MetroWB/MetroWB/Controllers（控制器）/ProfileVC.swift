//
//  ProfileVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//

import UIKit


/// 个人中心 主控制器
class ProfileVC: BaseViewController {
    
    // 微博模型
    var model: StatusModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏左侧视图
        self.setLeftBarItem(title: "个人详情", icon: nil)
    }
    
    // 加载数据
    override func setItemsAndTitlesData() {
        
        let user = MTNetWorkTools.shared.userAccess
        
        let detialVC = ProfileDetialVC()
        detialVC.userModel = user
        
        let statusVC = ProfileStatusVC()
        statusVC.userModel = user
        
        let fansVC = ProfileFansVC()
        fansVC.userModel = user
        
        let followVC = ProfileFollowVC()
        followVC.userModel = user
        
        items = [detialVC, statusVC,fansVC, followVC]
        titles = ["  我的资料"," 微博"," 粉丝", "关注"]
        
    }
}
