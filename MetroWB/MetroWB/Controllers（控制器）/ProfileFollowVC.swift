//
//  ProfileFollowVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//


import UIKit
import SnapKit
import MJRefresh
import HandyJSON
import SwiftyJSON

/// 关注控制器
class ProfileFollowVC: BaseChildVC {
    
    // cellID
    var cellID = "followcell"
    
    // 用户
    var userModel:UserModel?
    // 评论列表模型
    lazy var followModels:[UserModel] = {
        
        return [UserModel]()
    }()
    
    lazy var followModel:UserFollowersModel = UserFollowersModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 设置界面
    func setupUI() {
        
        // 设置tableivew 高度减去 底部工具条高度
//        self.followTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
}

/// 加载数据方法
extension ProfileFollowVC {
    
    // 根据微博id加载评论数组
    override func loadData(){
        
        MTNetWorkTools.shared.UserFollowList(uid: self.userModel!.id.description, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = UserFollowersModel.deserialize(from: dict.rawString()),
            let follows = result.users else {
                return
            }
            
            self.followModel = result
            let temp = follows + self.followModels
            
            self.followModels = temp
            self.someTableView.reloadData()
            self.someTableView.mj_header.endRefreshing()
            
        }) { (errmsg) in
            
            MTAlertView().showInfo(msg: errmsg, inview: nil, duration: 2)
            self.someTableView.mj_header.endRefreshing()
        }
    }
    
    // 查看给更多关注
    override func loadMore() {
        
        MTNetWorkTools.shared.UserFollowList(uid: self.userModel!.id.description, cursor: self.followModel.next_cursor, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = UserFollowersModel.deserialize(from: dict.rawString()),
            let follows = result.users else {
                return
            }
            
            self.followModel = result
            let taginx = IndexPath(row: self.followModels.count - 1, section: 0)
            
            let temp =  self.followModels + follows
            self.followModels = temp
            self.someTableView.reloadData()
             self.someTableView.scrollToRow(at: taginx, at: UITableView.ScrollPosition.bottom, animated: false)
            
            self.someTableView.mj_header.endRefreshing()
            
        }) { (errmsg) in
            
            MTAlertView().showInfo(msg: errmsg, inview: nil, duration: 2)
            self.someTableView.mj_header.endRefreshing()
        }
    }
}



/// 代理和数据源方法
extension ProfileFollowVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.followModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.cellForRow(at: indexPath)//dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        }
        
        let model = self.followModels[indexPath.row]
        
        let url = URL(string: model.avatar_large!)
        cell?.imageView?.kf.setImage(with: url, placeholder: UIImage(named: "default_img"))
        
        cell?.textLabel?.text = model.screen_name!
        cell?.detailTextLabel?.text = " " + model.genderStr + " " + model.location! + "   粉丝 " +
        "\(model.followers_count!)"
        
        
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100//self.commentsModel?.comments[indexPath.row].getHeight() ?? 0
    }
    
    
}
