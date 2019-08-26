//
//  UserFollowersModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/15.
//

import UIKit
import HandyJSON
import SwiftyJSON

// 用户关注列表模型
class UserFollowersModel: HandyJSON {

    var users:[UserModel]?
    var next_cursor:Int64!
    var previous_cursor:Int64!
    var total_number:Int64!
    
    required init(){}
    
}
