//
//  UnreadModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import HandyJSON
import SwiftyJSON

class UnreadModel: HandyJSON {

    /*
    "status": 0,
    "follower": 1,
    "cmt": 0,
    "dm": 1,
    "mention_status": 0,
    "mention_cmt": 0,
    "group": 0,
    "private_group": 0,
    "notice": 0,
    "invite": 0,
    "badge": 0,
    "photo": 0,
    "msgbox": 0
 */
    var status: Int = 0
     var follower: Int = 0
     var cmt: Int = 0 // 评论
     var dm: Int = 0
    var mention_status: Int = 0 // 提及我的微博
     var mention_cmt: Int = 0// 提及我的评论
     var group: Int = 0
     var private_group: Int = 0
     var notice: Int = 0
     var invite: Int = 0
    var badge: Int = 0
    var photo: Int = 0
    var msgbox: Int = 0
    
     required init() {}
    
}
