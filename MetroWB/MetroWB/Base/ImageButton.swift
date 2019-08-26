//
//  ImageButton.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/5.
//

import UIKit
import SnapKit
import Kingfisher
import AsyncDisplayKit



class ImageButton: UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func button(withUrl:String)->ImageButton{
        
        let buttonImg = ImageButton(type: .custom)
        
        // 动图标识
        let gifLable = UILabel()
        gifLable.text = "动图"
        gifLable.textColor = UIColor.white
        gifLable.backgroundColor = ConstFile.status_high_color
        gifLable.textAlignment = .center
        gifLable.font = UIFont.systemFont(ofSize: 10)
        buttonImg.addSubview(gifLable)
        
        gifLable.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(18)
            make.right.bottom.equalToSuperview()
        }
        
        if withUrl.contains(".GIF") || withUrl.contains(".gif") {
            gifLable.isHidden = false
        }else {
            gifLable.isHidden = true
        }
        
        let url = URL(string: withUrl)
        
        buttonImg.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "default_img"), options: nil, progressBlock: nil) { (result) in
            
            switch result {
            case .success(let value):
                
                let img = value.image
                let scale = (img.size.height)/(img.size.width)
                if scale > 3 {
                    gifLable.text = "长图"
                    gifLable.isHidden = false
                }
                
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
//        buttonImg.kf.setImage(with: url, for: .normal, placeholder: UIImage(named: "default_img"), options: nil, progressBlock: nil) { (img, err, type, url) in
//            
//            if img != nil {
//                let scale = (img!.size.height)/(img!.size.width)
//                if scale > 3 {
//                    gifLable.text = "长图"
//                    gifLable.isHidden = false
//                }
//            }
//        }
        
        buttonImg.imageView?.contentMode = .scaleAspectFill
        buttonImg.clipsToBounds = true

        return buttonImg
    }
    
}
