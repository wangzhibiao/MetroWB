//
//  BaseChildVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/12.
//

import UIKit
import MJRefresh


/// 该基础控制器是每个具体k界面的控制器 如 首页 消息  等
/// 与baseviewcontroller是 带有顶部导航的基础控制器
class BaseChildVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @objc dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    @objc dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    // 展示tableView
    lazy var someTableView:UITableView = {
        // 初始化表格视图
        var frame = self.view.bounds
        frame.size.height -= (ConstFile.bottomToolBarHeight + 44 + UIApplication.shared.statusBarFrame.size.height)
        var _statusTableView = UITableView(frame: frame)
        _statusTableView.backgroundColor = ConstFile.gloab_bg_color
        _statusTableView.delegate = self
        _statusTableView.dataSource = self
        _statusTableView.separatorStyle = .none
        return _statusTableView
        
    }()
    
    // 缓存ecell高度的数组
    var cacheCellHeightArray = [CGFloat]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // 加入表格
        self.view.addSubview(self.someTableView)
        
        // 设置顶部刷新
        let mjh = MJRefreshNormalHeader {
        
            self.cacheCellHeightArray.removeAll()
            self.loadData()
        }
        mjh?.lastUpdatedTimeLabel.isHidden = true
        mjh?.stateLabel.isHidden = true
        mjh?.arrowView.isHidden = true
        mjh?.activityIndicatorViewStyle = .gray
        mjh?.isAutomaticallyChangeAlpha = true
        mjh?.beginRefreshing()
        self.someTableView.mj_header = mjh
        // 底部刷新
        let mjf = MJRefreshBackNormalFooter {
            self.loadMore()
        }
        self.someTableView.mj_footer = mjf
        
    }
    
    // 加载数据 下拉刷新
    @objc dynamic func loadData(){
        self.someTableView.mj_header.endRefreshing()
    }
    // 加载更多 上拉刷新
    @objc dynamic func loadMore(){
        self.someTableView.mj_footer.endRefreshing()
    }

}
