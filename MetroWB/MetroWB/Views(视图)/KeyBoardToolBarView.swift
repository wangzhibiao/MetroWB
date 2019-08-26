//
//  KeyBoardToolBarView.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import SnapKit
import Material

/// 代理
protocol KeyBoardToolBarViewDelegate {
    func typeButtonClick(button: UIButton)
}

/// 按钮类型
enum KEYTYPE: Int {
    case AT = 0// @
    case TAG // #
    case PHOTO // 照片
    case CLOSE // 关闭
    case SEND// 发送
}

/// 键盘顶部的工具条
class KeyBoardToolBarView: UIView {

    
    var delegate: KeyBoardToolBarViewDelegate?
    var btnArray:[KEYTYPE] = [.CLOSE, .SEND]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        self.backgroundColor = ConstFile.gloab_bg_color
        var last:UIButton?
        for type in self.btnArray {
            
            switch type {
            case .AT:
                let btn = RaisedButton(image: UIImage(named: "compose_mentionbutton_background"), tintColor: .white)
                btn.tag = type.hashValue
                setupButtons(btn: btn, last: last)
                last = btn
                
            case .TAG:
                let btn = RaisedButton(image: UIImage(named: "compose_trendbutton_background"), tintColor: .white)
                btn.tag = type.hashValue
            
                setupButtons(btn: btn, last: last)
                last = btn
            case .PHOTO:
                let btn = RaisedButton(image: UIImage(named: "compose_toolbar_picture"), tintColor: .white)
                btn.tag = type.hashValue
                setupButtons(btn: btn, last: last)
                last = btn
            case .CLOSE:
                let btn = RaisedButton(title: "取消发表", titleColor: ConstFile.status_high_color)
                btn.tag = type.hashValue
                
                setupButtons(btn: btn, last: last)
                last = btn
            case .SEND:
                let btn = RaisedButton(title: "确认发表", titleColor: ConstFile.status_high_color)
                btn.tag = type.hashValue
               
                setupButtons(btn: btn, last: last)
                last = btn
            }
        }
        
    }
    
    
    /// 根据状态来布局按钮
    private func setupButtons(btn: UIButton, last: UIButton?){
        
        let btnw: CGFloat = self.frame.bounds.width/CGFloat(btnArray.count)
        btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
        btn.backgroundColor = ConstFile.gloab_repost_bg_color
         btn.setTitleColor(UIColor.white, for: .normal)
        self.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(btnw)
            if last == nil {
                make.left.equalToSuperview()
            }else {
                make.left.equalTo(last!.snp.right)
            }
        }
    }

    
    @objc func typeButtonClick(sender: UIButton){
        self.delegate?.typeButtonClick(button: sender)
    }
}
