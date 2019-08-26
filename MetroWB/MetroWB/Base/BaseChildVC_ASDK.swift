//
//  BaseChildVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/1.
//
import UIKit
import AsyncDisplayKit
import MJRefresh
import SnapKit


/// 使用AsyncDisplayKit 优化评论界面
class BaseChildVC_ASDK: UIViewController, BottomToolBarViewDelegate {
    
    // 底部工具条视图
    var bottomToolView = UIView()
    
    var node = ASTableNode()
    
    // MAKR: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ConstFile.gloab_bg_color
        node.backgroundColor = ConstFile.gloab_bg_color
        node.allowsSelection = true
        node.dataSource = self
        node.delegate = self
        node.view.separatorStyle = .none
        
        self.view.addSubnode(node)
        bottomToolView.backgroundColor =  ConstFile.gloab_bg_color
        let bottomnode = ASDisplayNode { () -> UIView in
            return self.bottomToolView
        }
        self.view.addSubnode(bottomnode)
        
        // 设置顶部刷新
        let mjh = MJRefreshNormalHeader {
            self.loadData()
        }
        mjh?.lastUpdatedTimeLabel.isHidden = true
        mjh?.stateLabel.isHidden = true
        mjh?.arrowView.isHidden = true
        mjh?.activityIndicatorViewStyle = .white
        mjh?.isAutomaticallyChangeAlpha = true
        mjh?.beginRefreshing()
        node.view.mj_header = mjh
        // 底部刷新
        let mjf = MJRefreshBackNormalFooter {
            self.loadMore()
        }
        node.view.mj_footer = mjf
        
        // 根据不同的界面要设置不同 inset 否则table显示不全
        //        setupTableInset()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = self.view.frame
        frame.size.height -= ConstFile.bottomToolBarHeight
        node.frame = frame
        
        let rect = CGRect(x: 0, y: frame.size.height, width: ConstFile.ScreenW, height: ConstFile.bottomToolBarHeight)
        bottomToolView.frame = rect
    }
    
    // 设置表格的inset
    @objc dynamic func setupTableInset(top: CGFloat = 0){
        node.contentInset = UIEdgeInsets(top: top, left: 0, bottom: ConstFile.bottomToolBarHeight, right: 0)
    }
    
    // 根据微博id加载评论数组
    @objc dynamic func loadData(){
        self.node.view.mj_header.endRefreshing()
    }
    
    @objc dynamic func loadMore() {
        self.node.view.mj_footer.endRefreshing()
    }
    
}

extension BaseChildVC_ASDK: ASTableDataSource, ASTableDelegate {
    
    @objc dynamic func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    @objc dynamic func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let nodeBlock: ASCellNodeBlock = {
            return ASCellNode(viewBlock: { () -> UIView in
                return UIView()
            })
        }
        return nodeBlock
    }
    
    @objc dynamic func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc dynamic func tableNode(_ tableNode: ASTableNode, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

/// 底部共具条代理
extension BaseChildVC_ASDK: MTAlertViewDelegate,WBHttpRequestDelegate {
    
    // 返回
    func backButtonClick() {
        self.navigationController?.popViewController(animated: false)
    }
    
    // 搜索按钮点击
    func searchButtonClick() {
        
    }
    
    // 设置d按钮点击
    func settingButtonClick() {
        
        let av = MTAlertView()
        av.delegate = self
        av.settingShow()
    }
    
    // 退出登录
    func logoutBtnClick() {
        WeiboSDK.logOut(withToken: MTNetWorkTools.shared.userAccess.access_token!, delegate: self, withTag: "logout")
        UserModel().saveUserAccess()
    }
    
    // 主页按钮点击 返回顶部加载新数据
    func scrolltotopButtonClick() {
        self.node.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        self.loadData()
        self.node.view.mj_header.beginRefreshing()
    }
    
    func request(_ request: WBHttpRequest!, didReceive response: URLResponse!) {
        
//        MTNetWorkTools.shared.UserInfo(uid: "uid", success: nil, failure: nil)
        let root = BaseNavigationVC(rootViewController: LoginViewController())
        present(root, animated: true, completion: nil)
    }
    
}


/// 微博文字和用户名点击代理方法
extension BaseChildVC_ASDK: StatusCell_ASDKDelegate {
    
    func statusTextClick(indexpath: IndexPath) {
        self.tableNode(node, didSelectRowAt: indexpath)
    
    }
    
    @objc func statusUserNameClick(name: String) {
        
    }
}
