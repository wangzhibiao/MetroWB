//
//  AnnotationsModel.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/4.
//

import UIKit
import SwiftyJSON
import HandyJSON

/// 短链接详细信息 如果是视频 投票 头条文字等 改类会有信息 普通链接 该类为nil
class AnnotationModel: HandyJSON {
    
    // "Video"
    var object_type:String!
    var object:ObjectModel!
    
    required init() {
        
    }
}

// 视频等类对象
class ObjectModel:HandyJSON {
    
    var display_name:String?
    var stream:StreamModel!// 如果是视频则这里有值 否则在 slide里
    var titles:[TitleModel]!
    var image:ArticlImageModel?
    var slide_cover:SlideModel?
    var video_orientation:String!
    var urls:UrlsModel?
    required init() {
        
    }
}

// 个别链接在urls中 目前只有一个属性 随时发现随时添加
class UrlsModel: HandyJSON {
    
    var hevc_mp4_hd:String?
    
    required init(){}
}

class SlideModel:HandyJSON {
    var slide_videos:[SlideVideosModel]!
    
    required init(){}
}

class SlideVideosModel:HandyJSON {
    
    
    var cover:String! // "http://wx3.sinaimg.cn/large/e73c06c3ly8g50g9bpbv9j20dc0no76c.jpg",
//    "protocol": "general",
//    "media_info": {
//    "camera_mode": 0
//    },
//    "create_time": 1563167793000,
//    "owner_id": 3879470787,
//    "nickname": "快手网红故事",
//    "expire_time": 1563167793000,
//    "segment_duration": 20267,
//    "segment_type": 0,
//    "avatar": "http://tva3.sinaimg.cn/crop.0.0.664.664.180/e73c06c3jw8fbw7l5bxy5j20ig0igmxh.jpg",
//    "segment_id": 4394306576840961,
    var url:String! // "http://f.us.sinaimg.cn/001op9yIlx07vrhjvKla010412005FOF0E010.mp4?label=mp4_hd&template=480x852.24.0&trans_finger=ecec65804687c67452eb0c6e74ae006d&Expires=1563172373&ssig=wGtZHPM4i3&KID=unistore,video"
    
    required init(){}
}


/// 微博头条中会有展位图
class ArticlImageModel:HandyJSON {
    var width:CGFloat!
    var height:CGFloat!
    var url:String!
    
    required init() {
        
    }
}


class StreamModel: HandyJSON {
    
    var duration:CGFloat!// 14.046,
    var format:String!// "mp4",
    var width:Int64!// 480,
    var hd_url:String?// "http://f.us.sinaimg.cn/001JSF4blx07v9z11A8U010412004dOW0E010.mp4?label=mp4_hd&template=480x640.24.0",
    var url:String!// "http://f.us.sinaimg.cn/002w6rbTlx07v9z0J5Ic010412003fH50E010.mp4?label=mp4_ld&template=360x480.24.0",
    var height:Int64!// 640
    
    
    required init() {
        
    }
}

class TitleModel: HandyJSON {
    
    var title:String!// "买二送三（共五个）；买四发十个！！！"
    required init() {
        
    }
}
