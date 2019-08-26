//
//  ProfileFansVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//


import UIKit
import SnapKit
import MJRefresh
import HandyJSON
import SwiftyJSON

/// 粉丝控制器
class ProfileFansVC: UIViewController {
    
    // 列表
    var fansTableView:UITableView!
    // cellID
    var cellID = "fanscell"
    
    // 用户
    var userModel:UserModel?
    // 评论列表模型
    var funsModels:[UserModel]?{
        didSet{
            guard let _ = funsModels else { return }
            
            self.fansTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // 设置界面
    func setupUI() {
        
        // 设置tableivew 高度减去 底部工具条高度
        var frame = self.view.bounds
        frame.size.height -= (ConstFile.bottomToolBarHeight + 44 + UIApplication.shared.statusBarFrame.size.height)
        self.fansTableView = UITableView(frame: frame)
        self.view.addSubview(self.fansTableView)
        
        self.fansTableView.backgroundColor = ConstFile.gloab_bg_color
        self.fansTableView.separatorStyle = .none
        self.fansTableView.delegate = self
        self.fansTableView.dataSource = self
        
        self.fansTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let mjh = MJRefreshNormalHeader {
            
            //            self.showLoading(tag: self)
            self.loadData()
        }
        mjh?.lastUpdatedTimeLabel.isHidden = true
        mjh?.stateLabel.isHidden = true
        mjh?.arrowView.isHidden = true
        mjh?.activityIndicatorViewStyle = .gray
        mjh?.isAutomaticallyChangeAlpha = true
        self.fansTableView.mj_header = mjh
        self.fansTableView.mj_header.beginRefreshing()
    }
    
}

/// 加载数据方法
extension ProfileFansVC {
    
    // 根据微博id加载评论数组
    func loadData(){
        
        MTNetWorkTools.shared.UserFansList(uid: self.userModel!.id.description, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = [UserModel].deserialize(from: dict["users"].rawString()) else {
                return
            }
            
            self.funsModels = (result as! [UserModel])
            self.fansTableView.mj_header.endRefreshing()
            
        }) { (errmsg) in
            
            MTAlertView().showInfo(msg: errmsg, inview: nil, duration: 2)
            self.fansTableView.mj_header.endRefreshing()
        }
        
    }
}



/// 代理和数据源方法
extension ProfileFansVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.funsModels  == nil ? 0 : self.funsModels!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let model = self.funsModels![indexPath.row]
        
        let url = URL(string: model.avatar_large!)
        cell.imageView?.kf.setImage(with: url, placeholder: UIImage(named: "default_img"))
        
        cell.textLabel?.text = model.screen_name!
        cell.detailTextLabel?.text = model.genderStr + " " + model.location! + " " +
        "\(String(describing: model.followers_count))"
        
        
 
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100//self.commentsModel?.comments[indexPath.row].getHeight() ?? 0
    }
    
    
}
