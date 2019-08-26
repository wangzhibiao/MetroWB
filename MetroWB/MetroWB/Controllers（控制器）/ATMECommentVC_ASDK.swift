//
//  ATMECommentVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import MJRefresh
import SwiftyJSON
import HandyJSON
import AsyncDisplayKit
import Material

/// @我的评论控制器
class ATMECommentVC_ASDK: BaseChildVC_ASDK {
    
    
    // 评论列表模型
    lazy var statusArrayModel:StatusCommentsModel = {
        
        var model = StatusCommentsModel()
        model.comments = [StatusCommentModel]()
        return model
    }()
    
    // 当前选择的model
    var currentModel:StatusCommentModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

/// 加载数据方法
extension ATMECommentVC_ASDK {
    
    // 根据微博id加载评论数组
    override func loadData(){
        
        var someid:Int64 = 0
        if  self.statusArrayModel.comments!.count > 0 {
            someid = self.statusArrayModel.comments!.first!.id
        }
        
        MTNetWorkTools.shared.AtMeCommentRequest(since_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = StatusCommentsModel.deserialize(from: dict.rawString()),
                let comments = result.comments else {
                    
                    MTAlertView().showInfo(msg: "未能获取数据", inview: self.node.view, duration: 2)
                    self.node.view.mj_header.endRefreshing()
                    return
            }
            
            let temp = comments + self.statusArrayModel.comments
            
            self.statusArrayModel.comments = temp
            self.node.reloadData()
            self.node.view.mj_header.endRefreshing()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }
    
    override func loadMore() {
        var someid:Int64 = 0
        if  self.statusArrayModel.comments!.count > 0 {
            someid = self.statusArrayModel.comments!.last!.id
        }
        
        MTNetWorkTools.shared.AtMeCommentRequest(max_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = StatusCommentsModel.deserialize(from: dict.rawString()),
                let comments = result.comments else {
                    
                    MTAlertView().showInfo(msg: "未能获取数据", inview: self.node.view, duration: 2)
                    self.node.view.mj_footer.endRefreshing()
                    return
            }
            
            
            
            let taginx = IndexPath(row: self.statusArrayModel.comments!.count - 1, section: 0)
            let temp = self.statusArrayModel.comments + comments
            
            self.statusArrayModel.comments = temp
            
            self.node.reloadData()
            self.node.scrollToRow(at: taginx, at: UITableView.ScrollPosition.bottom, animated: false)
            
            self.node.view.mj_footer.endRefreshing()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
    }
}

/// 代理和数据源方法
extension ATMECommentVC_ASDK {
    
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return  self.statusArrayModel.comments.count
    }
    
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let block: ASCellNodeBlock = {
            
            let cell = ATMEStatusAndCmtCell_ASDK(model: self.statusArrayModel.comments[indexPath.row])
            cell.delegate = self
            return cell
        }
        
        return block
        
    }
    
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let drpVC = StatusDRPVC()
        drpVC.model = self.statusArrayModel.comments[indexPath.row].status
        self.navigationController?.pushViewController(drpVC, animated: false)
    }
    
    
}


/// 回复f评论代理方法
extension ATMECommentVC_ASDK: BaseTextEditorVCDelegate, ATMEStatusAndCmtCell_ASDKDelegate {
    
    func replyButtonClick(model: StatusCommentModel) {
        
        self.currentModel = model
        let hoder = "回复：" + model.user!.screen_name!
        let modalVC = TextEditorVC(placeHolder: hoder, title: "回复评论")
        modalVC.delegate = self
        let tagVC = BaseNavigationVC(rootViewController: modalVC)
        
        DispatchQueue.main.async {
            self.present(tagVC, animated: true, completion: nil)
        }
    }
    
    
    /// 发送评论
    func commitSend(txt: String) {
        
        // 回复评论
        MTNetWorkTools.shared.createReplyCommentRequest(statusID: self.currentModel.status!.id.description, comment: txt, cid: self.currentModel.idstr, success: { (json) in
            
            MTAlertView().showInfo(msg: "回复成功", inview: nil, duration: 2)
            self.loadData()
        }) { (error) in
            
            MTAlertView().showInfo(msg: error, inview: nil, duration: 1, alignment: .left)
        }
        
    }
}
