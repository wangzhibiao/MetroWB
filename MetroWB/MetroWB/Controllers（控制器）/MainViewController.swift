//
//  MainViewController.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/21.
//

import UIKit
import Tabman
import Pageboy

class MainViewController: BaseViewController  {

   
    override func viewDidLoad() {
        super.viewDidLoad()
    
       setupCurrentUserInfo()
    }
    
    // 设置当前用户细腻
    func setupCurrentUserInfo(){
        
        // 设置导航栏左侧视图
        let uac = UserModel.getUserAccess()
        MTNetWorkTools.shared.UserInfo(uid: uac.id.description, success: { (json) in
            
            if let user = UserModel.deserialize(from: json) {
                // 保存当前登录用户
                let uac = UserModel.getUserAccess()
                user.access_token = uac.access_token
                user.expires_in = uac.expires_in
                user.saveUserAccess()
                // 设置左上角信息
                self.setLeftBarItem(title: user.screen_name!, icon: user.avatar_large)
            }
            
        }) { (error_msg) in
            // 设置左上角信息
//            self.setLeftBarItem(title: MTNetWorkTools.shared.currentLoginUser.screen_name!, icon: MTNetWorkTools.shared.currentLoginUser.avatar_large)
        }
    }
    
    override func setItemsAndTitlesData() {
        items = [HomeViewController_ASDK(), MessageViewController(),FavoritesVC_ASDK()]
        titles = [" 首页"," 消息"," 收藏"]
    }
    
    // 发微博点击
    override func addButtonClick() {
        
        let modalVC = TextEditorVC(placeHolder: "发现新鲜事", title: "发动态")
        let tagVC = BaseNavigationVC(rootViewController: modalVC)
        
        self.present(tagVC, animated: true) {
            
        }
    }
}

