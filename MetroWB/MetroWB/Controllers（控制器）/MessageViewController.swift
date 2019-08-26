//
//  MessageViewController.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/31.
//

import UIKit
import AsyncDisplayKit
import HandyJSON
import SwiftyJSON


// 消息控制器
class MessageViewController: BaseChildVC_ASDK {

    // 数据源
    var types = ["@我的","评论"]
    var subTitles = ["暂时没有新消息","暂时没有新消息"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.node.view.mj_footer = nil
    }
    
    override func loadData() {
        
        MTNetWorkTools.shared.UnreadCountRequset(uid: MTNetWorkTools.shared.userAccess.id.description, success: { (json) in
            
            let dict = JSON(parseJSON: json)
            guard let unreadModel = UnreadModel.deserialize(from: dict.rawString()) else {
                self.node.view.mj_header.endRefreshing()
                return
            }
            
            if unreadModel.cmt > 0 {
                self.subTitles[1] = "您收到\(unreadModel.cmt)条新消息"
            }
            if unreadModel.mention_cmt > 0 {
                 self.subTitles[0] = "您收到\(unreadModel.mention_cmt)条@您的新消息"
            }
            if unreadModel.mention_status > 0 {
                 self.subTitles[0] = "您收到\(unreadModel.mention_status)条@您的新微博"
            }
            
            MTLog(msg: "新消息： \(unreadModel.cmt)")
            MTLog(msg: "@新消息： \(unreadModel.mention_cmt)")
            MTLog(msg: "@新微博： \(unreadModel.mention_cmt)")
            self.node.reloadData()
            self.node.view.mj_header.endRefreshing()
            
        }) { (err) in
            
            MTAlertView().showInfo(msg: err, inview: self.node.view, duration: 2)
            self.node.view.mj_header.endRefreshing()
        }
    }

}


extension MessageViewController {
    
    override func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    override func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
       
        let nodeBlock: ASCellNodeBlock = {
            return MessageCell_ASDK(title: self.types[indexPath.row], subTitle: self.subTitles[indexPath.row])
        }
        
        return nodeBlock
    }
    
    override func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(AtMeVC(), animated: false)
        default:
            self.navigationController?.pushViewController(CommentVC(), animated: false)
        }
        
    }
    
}
