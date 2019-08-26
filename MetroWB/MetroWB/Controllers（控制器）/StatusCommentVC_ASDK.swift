//
//  StatusCommentVC_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/31.
//

import UIKit
import AsyncDisplayKit
import HandyJSON
import SwiftyJSON
import MJRefresh

/// 使用AsyncDisplayKit 优化评论界面
class StatusCommentVC_ASDK: BaseChildVC_ASDK {

    // 微博
    var statusModel:StatusModel?
    // 评论列表模型
    lazy var commentsModel:StatusCommentsModel = {
        
        var model = StatusCommentsModel()
        model.comments = [StatusCommentModel]()
        return model
    }()

    // 评论id 如果id不为空 则证明是回复评论 否则 是回复微博
    var cid:String?
    // 当前的indexpatch 在i评论后刷新
    var currentModel:StatusCommentModel?
    
    // MAKR: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 根据微博id加载评论数组
    override func loadData(){
        
        var someid:Int64 = 0
        if  self.commentsModel.comments.count > 0 {
            someid = self.commentsModel.comments!.first!.id
        }
        
        MTNetWorkTools.shared.statusCommentsRequest(status: self.statusModel!,since_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = StatusCommentsModel.deserialize(from: dict.rawString()) else {
                
                MTAlertView().showInfo(msg: "未能获取数据", inview: self.node.view, duration: 2)
                self.node.view.mj_header.endRefreshing()
                return
            }
            
            
            let temp = result.comments + self.commentsModel.comments
            
            self.commentsModel.comments = temp
            self.node.reloadData()
            self.node.view.mj_header.endRefreshing()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }
    
    
    override func loadMore() {
        var someid:Int64 = 0
        if  self.commentsModel.comments!.count > 0 {
            someid = self.commentsModel.comments!.last!.id
        }
        
        MTNetWorkTools.shared.statusCommentsRequest(status: self.statusModel!,max_id: someid, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let result = StatusCommentsModel.deserialize(from: dict.rawString()),
                let comments = result.comments else {
                    
                    MTAlertView().showInfo(msg: "未能获取数据", inview: self.node.view, duration: 2)
                    self.node.view.mj_footer.endRefreshing()
                    return
            }
            
            
            
            let taginx = IndexPath(row: self.commentsModel.comments!.count - 1, section: 0)
            let temp = self.commentsModel.comments + comments
            
            self.commentsModel.comments = temp
            
            self.node.reloadData()
            self.node.scrollToRow(at: taginx, at: UITableView.ScrollPosition.bottom, animated: false)
            
            self.node.view.mj_footer.endRefreshing()
            
        }) { (err_msg) in
            MTAlertView().showInfo(msg: err_msg, inview: nil, duration: 2)
            self.node.view.mj_footer.endRefreshing()
        }
    }

}

extension StatusCommentVC_ASDK: BaseTextEditorVCDelegate {
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.commentsModel.comments.count
    }
    
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
       
        let model = self.commentsModel.comments[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = StatusCommentCell_ASDK(model: model)
            cell.delegate = self
            return cell
        }
        return nodeBlock
    }
    
    // 回复评论
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
         let model = self.commentsModel.comments[indexPath.row]
        
        let hoder = "回复：" + model.user.screen_name!
        self.cid = model.idstr
        
        let modalVC = TextEditorVC(placeHolder: hoder, title: "回复评论")
        modalVC.delegate = self
        let tagVC = BaseNavigationVC(rootViewController: modalVC)
        
        DispatchQueue.main.async {
            self.present(tagVC, animated: true, completion: nil)
        }
        
    }
    
    // 评论微博
    func editButtonClick() {
        
        let model = self.statusModel!
        // 必须置空 否则会导致错乱回复
        self.cid = nil
        let hoder = "回复：" + model.user!.screen_name!
        let modalVC = TextEditorVC(placeHolder: hoder, title: "发表评论")
        modalVC.delegate = self
        let tagVC = BaseNavigationVC(rootViewController: modalVC)
        
        DispatchQueue.main.async {
            self.present(tagVC, animated: true, completion: nil)
        }
    }
    
    
    /// 发送评论
    func commitSend(txt: String) {
        
        // 评论微博
        if self.cid == nil {
           
            MTNetWorkTools.shared.createCommentRequest(statusID: self.statusModel!.id.description, comment: txt, success: { (json) in
                
                MTAlertView().showInfo(msg: "评价成功", inview: nil, duration: 2)
                self.loadData()
            }) { (error) in
                
                MTAlertView().showInfo(msg: error, inview: nil, duration: 1, alignment: .left)
            }
            
        }else {// 回复评论
            
            MTNetWorkTools.shared.createReplyCommentRequest(statusID: self.statusModel!.id.description, comment: txt, cid: self.cid!, success: { (json) in

                MTAlertView().showInfo(msg: "回复成功", inview: nil, duration: 2)
                self.loadData()
                self.cid = nil
            }) { (error) in

                MTAlertView().showInfo(msg: error, inview: nil, duration: 1, alignment: .left)
                self.cid = nil
            }
        }
    }
    
}

/// 删除代理
extension StatusCommentVC_ASDK: StatusCommentCell_ASDKDelegate {
    
    // 删除按钮点击
    func delButtonClick(model: StatusCommentModel) {
        
        let art = MTAlertView.init()
        art.delegate = self
        art.okShow(msg: "确认删除么")
//        art.show()
        self.currentModel = model
        
    }
    
    // 确认删除按钮点击
    func commitBtnClick(sender: UIButton) {
        
        let inx = self.commentsModel.comments.firstIndex { (m) -> Bool in
            m.idstr == self.currentModel!.idstr
        }
        let inxpath = IndexPath(row: inx!, section: 0)
        self.commentsModel.comments.remove(at: inx!)
        MTNetWorkTools.shared.delCommentRequest(cid: self.currentModel!.idstr, success: { (json) in
            MTAlertView().showInfo(msg: "删除成功", inview: nil, duration: 2)
            self.node.deleteRows(at: [inxpath], with: .automatic)
        }) { (error_msg) in
            MTAlertView().showInfo(msg: error_msg, inview: nil, duration: 2)
        }
    }
    
   /*
     func commitButtonClick(tag: Bool) {
     
     if tag {
     let inx = self.commentsModel.comments.firstIndex { (m) -> Bool in
     m.idstr == self.currentModel!.idstr
     }
     let inxpath = IndexPath(row: inx!, section: 0)
     self.commentsModel.comments.remove(at: inx!)
     MTNetWorkTools.shared.delCommentRequest(cid: self.currentModel!.idstr, success: { (json) in
     MTAlertView().showInfo(msg: "删除成功", inview: nil, duration: 2)
     self.node.deleteRows(at: [inxpath], with: .automatic)
     }) { (error_msg) in
     MTAlertView().showInfo(msg: error_msg, inview: nil, duration: 2)
     }
     }
     }
     */
    
}
