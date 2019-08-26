//
//  AouthModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/23.
//

import Foundation

class AouthModel: Codable {
    
    var name:String
    var lines:[tempModel]
    
    
}


class tempModel: Codable {
    
    
    var line:String?
    
}

