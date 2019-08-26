//
//  UserCountsModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//

import UIKit
import HandyJSON
import SwiftyJSON

/// 用户粉丝 z关注  微博数模型
class UserCountsModel: HandyJSON {

    var id:String!
    var followers_count: String!
    var friends_count: String!
    var statuses_count: String!
    
    required init(){}
    
}
