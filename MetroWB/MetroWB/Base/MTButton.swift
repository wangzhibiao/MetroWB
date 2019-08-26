//
//  MTButton.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/21.
//

import UIKit
import Kingfisher
import SnapKit

/// 继承自UIButton的Metro 风格的按钮
class MTButton: UIButton {

   // 动图标识
    lazy var gifLable = UILabel()
    // url
    var url:String?{
        didSet{
            if let imgUrl = url {
                
                if imgUrl.contains(".GIF") || imgUrl.contains(".gif") {
                    gifLable.isHidden = false
                }else {
                    gifLable.isHidden = true
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefault()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefault()
    }
    

}


// 设置默认的Metro风格更
extension MTButton {
    
    func setDefault(){
        
        self.backgroundColor = ConstFile.gloab_bg_color//UIColor.black
        self.layer.borderColor = UIColor.white.cgColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        // 动图标识
        gifLable.text = "动图"
        gifLable.textColor = UIColor.white
        gifLable.backgroundColor = UIColor.green
        gifLable.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(gifLable)
        
        gifLable.snp.makeConstraints { (make) in
            make.width.equalTo(44)
            make.height.equalTo(20)
            make.right.bottom.equalToSuperview()
        }
    
    }
    
    
    
}
