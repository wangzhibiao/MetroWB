//
//  FavoritesModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//

import UIKit
import HandyJSON
import SwiftyJSON


/// 收藏微博模型
class FavoritesModel: HandyJSON {
    
    var status:StatusModel!
    var favorited_time:String!
    var tags:[TagModel]!
    
     required init() {}
    

}

/// 标签模型
class TagModel:HandyJSON {
    
    var id:Int64!
    var tag:String!
    
    required init(){}
}

