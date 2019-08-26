//
//  BaseViewController.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/30.
//

import UIKit
import Tabman
//import NVActivityIndicatorView
import Kingfisher
import Pageboy
import SnapKit

// 基础控制器 集成TabMan 以及提供基础的展示|隐藏 有商家刷新控件 设置左上角图标和文字的方法
class BaseViewController: TabmanViewController {
    
    var items:[UIViewController] = []
    var titles:[String] = []

    // 刷新控件
//    private var loadingView:NVActivityIndicatorView!
    public var bottomToolView:BottomToolBarView!
    // 是否正在显示底部工具条
    var isShowBottomToolView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = ConstFile.gloab_bg_color
        // 所有子控制器需要重写这个方法来确保 items和titles 有数据
        setItemsAndTitlesData()
        setupTopNav()
    }
    
    // 设置顶部界面
    func setupTopNav(){
        // 设置顶部分页导航栏
        self.dataSource = self
        self.delegate = self
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .progressive
        bar.backgroundColor = ConstFile.gloab_nav_color//UIColor.black
        bar.backgroundView.style = .clear
        bar.fadesContentEdges = true
        
        
        bar.indicator.weight = .custom(value: 0)
        bar.buttons.customize { (button) in
            button.selectedTintColor = Color.white
            button.tintColor = ConstFile.gloab_font_color
            button.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            button.selectedFont = UIFont.systemFont(ofSize: 30, weight: .bold)
        }
        
        addBar(bar, dataSource: self, at: .top)
    }
    
    
    /// 在设置界面前 先获取自控制器数据 子类通过重写此方法来设置自己的数据
    func setItemsAndTitlesData(){
        
    }
    /// 设置底部工具条
    func setBottomToolBarView()-> BottomToolBarView{
        return BottomToolBarView()
    }
    
    // 设置导航栏左侧的图标和文字
    func setLeftBarItem(title: String, icon: String?){
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        let imgv = UIImageView(frame: CGRect(x: -5, y: 10, width: 34, height: 34))
        imgv.clipsToBounds = true

        let url = URL(string: icon ?? "")
        imgv.kf.setImage(with: url)
//        imgv.kf.setImage(with: url, placeholder: UIImage(named: "default_user"), options: nil, progressBlock: nil, completionHandler: nil)
        
        leftView.addSubview(imgv)

        let txtV = UILabel(frame: CGRect(x: 34, y: 10, width: 200, height: 34))
        txtV.text = title
        txtV.textColor = ConstFile.gloab_font_color
        txtV.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        leftView.addSubview(txtV)
        let leftItem = UIBarButtonItem(customView: leftView)
        
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    
    /// 导航栏右上角显示刷新控件
    func showLoading(tag: UIViewController){
//        let frame = CGRect(x: 0, y: 0, width: 70, height: 44)
//        loadingView = NVActivityIndicatorView(frame: frame, type: .ballPulse, color: UIColor.black, padding: 50)
//        tag.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingView)
//
//        loadingView.startAnimating()
    }
    /// 隐藏刷新控件
    func hideLoading(tag: UIViewController){
        
        tag.navigationItem.rightBarButtonItem = nil
        
//        if loadingView != nil {
//            loadingView.stopAnimating()
//        }
    }
    
    // 几个控制器
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return items.count
    }
    
    // 控制器实例
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
       
        return items[index]
    }
    // 默认控制器
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        
        return .first
    }
    
    
    // 控制器title
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        let item = TMBarItem(title: titles[index])
        
        return item
    }
    
    // 顶部控制器切换
    override func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: TabmanViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        
        showBottomToolView(index: index)
    }
    
    // 显示底部工具条
    func showBottomToolView(index: Int){
        if bottomToolView != nil {
            bottomToolView.hide()
        }
        
        if titles.count == 0 { return }
       
        let title = titles[index].replacingOccurrences(of: " ", with: "")
        if vctitles[title]?.count == nil {
            return
        }
        bottomToolView = BottomToolBarView(buttons: vctitles[title]!)

        if items[index].isKind(of: BaseChildVC_ASDK.self) {
            
            let v = (items[index] as! BaseChildVC_ASDK).bottomToolView
            bottomToolView.show(inView: v)
            isShowBottomToolView = true
            bottomToolView.delegate = (items[index] as! BaseChildVC_ASDK) //as? BottomToolBarViewDelegate
        }
        
    
        
    }
    
    
    // 工具条各个代理方法
    func addButtonClick() {
        
    }
    func searchButtonClick() {
        
    }
    func settingButtonClick() {
        
    }
    func backButtonClick() {
        self.bottomToolView.hide()
        self.navigationController?.popViewController(animated: false)
    }
    func menusButtonClick() {
        
    }
    func moreButtonClick() {
        
    }
    
    func profileButtonClick() {
        self.navigationController?.pushViewController(ProfileVC(), animated: false)
    }
    
    // 各个控制器底部工具按钮的数组
    var vctitles = [
        "首页":[.SCROLLTOTOP,.SETTING],
        "正文":[ToolBarButtonType.BACK,.KEEP, .LINKTOWEIBO],
        "评论":[ToolBarButtonType.EDIT],
        "转发":[ToolBarButtonType.BACK,.SETTING, .MORE],
        "原文":[ToolBarButtonType.BACK, .KEEP, .LINKTOWEIBO],
        "原文评论":[ToolBarButtonType.EDIT],
        
        "消息":[.SETTING],
        "@我的微博":[.BACK],
        "@我的评论":[.BACK],
        "我收到的评论":[.BACK],
        "我发出的评论":[.BACK],
        
        "收藏":[.SETTING],
        "我的资料":[.BACK,.SETTING],
        "微博":[.BACK,.SEARCH],
        "粉丝":[.BACK,.SEARCH],
        "关注":[.BACK,.SEARCH]
        
    ]
    

}

// 控制器的数据源和代理方法
extension BaseViewController: PageboyViewControllerDataSource,TMBarDataSource,BottomToolBarViewDelegate{
    
   
    
}
