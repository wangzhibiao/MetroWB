//
//  ProfileDetialVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//

import HandyJSON
import SwiftyJSON
import MJRefresh

/// 个人详情控制器
class ProfileDetialVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // 展示微博的tableView
    var profileTableView:UITableView!
    // cellid
    var cellID = "profileCellID"
    
    
    // 用户
    var userModel:UserModel? {
        didSet{
            guard let _ = userModel else {
                return
            }
            
            if self.profileTableView != nil {
                self.profileTableView.reloadData()
            }
          
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
    }
    
    
    func loadData(){
       
        MTNetWorkTools.shared.UserInfo(uid: self.userModel!.id.description, success: { (json) in
        
            let dict = JSON(parseJSON: json)
            guard let result = UserModel.deserialize(from: dict.rawString()) else {
                return
            }
            
            self.userModel = (result)
            self.profileTableView.mj_header.endRefreshing()
            
        }) { (errmsg) in
            
            MTAlertView().showInfo(msg: errmsg, inview: nil, duration: 2)
            self.profileTableView.mj_header.endRefreshing()
            
        }
    }
    
}

extension ProfileDetialVC {
    
    func setupUI(){
        
        // 控制器背景颜色
        self.view.backgroundColor = ConstFile.gloab_bg_color
        // 初始化表格视图
        var frame = self.view.bounds
        frame.size.height -= (ConstFile.bottomToolBarHeight + 44 + UIApplication.shared.statusBarFrame.size.height)
        self.profileTableView = UITableView(frame: frame)
        self.profileTableView.backgroundColor = ConstFile.gloab_bg_color
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        self.profileTableView.separatorStyle = .none
        
        // 注册cell
        self.profileTableView.register(ProfileDetialCell.self, forCellReuseIdentifier: cellID)
        
        self.view.addSubview(self.profileTableView)
        
        let mjh = MJRefreshNormalHeader {
            
            //            self.showLoading(tag: self)
            self.loadData()
        }
        mjh?.lastUpdatedTimeLabel.isHidden = true
        mjh?.stateLabel.isHidden = true
        mjh?.arrowView.isHidden = true
        mjh?.activityIndicatorViewStyle = .gray
        mjh?.isAutomaticallyChangeAlpha = true
        self.profileTableView.mj_header = mjh
        // 首次加载不刷新
        self.profileTableView.reloadData()

        
        
    }
    
}


// 数据源和代理方法
extension ProfileDetialVC {
    
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  1
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProfileDetialCell
        
            cell.model = self.userModel
            
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    
    
}
