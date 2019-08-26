//
//  BottomToolBarView.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/20.
//

import UIKit
import SnapKit
import Material

/// 菜单按钮的枚举类型
enum ToolBarButtonType: Int {
    /// 返回
    case BACK = 0
    /// 搜索
    case SEARCH
    /// 菜单
    case MENUS
    /// 增加
    case ADD
    case SETTING// 设置
    case MORE// 更多
    /// 个人
    case PROFILE// 个人
    /// 收藏
    case KEEP // 收藏
    /// 评论
    case COMMENT // 评论
    /// 编辑
    case EDIT // 编辑
    /// 转发
    case REPOST //转发
    
    case DELETE // 删除
    /// 链接到微博原生app
    case LINKTOWEIBO
    /// 滚动到顶部刷新加载数据
    case SCROLLTOTOP
    
    
}

// 代理方法
@objc protocol BottomToolBarViewDelegate {
    @objc optional func backButtonClick()
    @objc optional func searchButtonClick()
    @objc optional func menusButtonClick()
    @objc optional func addButtonClick()
    @objc optional func settingButtonClick()
    @objc optional func moreButtonClick()
    @objc optional func profileButtonClick()
    @objc optional func keepButtonClick()
    @objc optional func commentButtonClick()
    @objc optional func editButtonClick()
    @objc optional func repostButtonClick()
    @objc optional func deleteButtonClick()
    @objc optional func linketoweiboButtonClick()
    @objc optional func scrolltotopButtonClick()
    
}

/// 底部的工具条 包含 返回 发布 设置等
class BottomToolBarView: UIView {

    var delegate: BottomToolBarViewDelegate?
    // 布局按钮的stackview
    var layoutStackView:UIStackView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
     init(buttons: [ToolBarButtonType]){
       
        let h:CGFloat = ConstFile.bottomToolBarHeight
        let frame = CGRect(x: 0,y: ConstFile.ScreenH,width: ConstFile.ScreenW,height: h)
        super.init(frame: frame)
        
        if buttons.count == 0 {return}
        
        let margin:CGFloat = 1
        self.layoutStackView = UIStackView()
        self.layoutStackView.alignment = .center
        self.layoutStackView.axis = .horizontal
        self.layoutStackView.spacing = margin
        self.layoutStackView.distribution = .equalSpacing
//        self.layoutStackView.backgroundColor = UIColor.green
        self.addSubview(self.layoutStackView)
        
        // 根据按钮数量计算按钮宽度
        let btnW: CGFloat = (ConstFile.ScreenW - CGFloat(1 + buttons.count)) / CGFloat(buttons.count)
        
        // 根据按钮个数来设置宽度
        let stackVW:CGFloat = CGFloat(buttons.count) * btnW + 0//CGFloat(buttons.count - 1) * margin
        
        self.layoutStackView.snp.makeConstraints { (make) in
            make.height.equalTo(h)
            make.top.equalToSuperview().offset(0)
            make.centerX.equalToSuperview()
            make.width.equalTo(stackVW)
            
        }
        
        // 最终返回的工具条视图
        self.backgroundColor = ConstFile.gloab_bg_color//UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        
        for button in buttons {
            switch button {
            case .BACK:
                
                let backBtn = RaisedButton(image: Icon.arrowBack, tintColor: .white)
                backBtn.tag = ToolBarButtonType.BACK.rawValue
                 backBtn.backgroundColor = ConstFile.gloab_repost_bg_color
                backBtn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(backBtn)
                
                backBtn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
                
            case .SETTING:

                let btn = RaisedButton(image: Icon.settings, tintColor: .white)
                btn.tag = ToolBarButtonType.SETTING.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
                
            case .SEARCH:
                let btn = RaisedButton(image: Icon.search, tintColor: .white)
                btn.tag = ToolBarButtonType.SEARCH.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
                
            case .ADD:
               
                let btn = RaisedButton(image: Icon.add, tintColor: .white)
                btn.tag = ToolBarButtonType.ADD.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
                
            case .EDIT:
                
                let btn = RaisedButton(image: Icon.pen, tintColor: .white)
                btn.tag = ToolBarButtonType.EDIT.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            case .LINKTOWEIBO:
                let btn = RaisedButton(image: Icon.cm.shuffle, tintColor: .white)
                btn.tag = ToolBarButtonType.LINKTOWEIBO.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            case .KEEP:
//                let btn = BottomToolBarView.ButtonHas(title: nil, img: Icon.cm.star, tag: ToolBarButtonType.KEEP.rawValue)
                let btn = RaisedButton(image: Icon.cm.star, tintColor: .white)
                btn.tag = ToolBarButtonType.KEEP.rawValue
                 btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            case .MENUS:

                let btn = RaisedButton(image: Icon.moreHorizontal, tintColor: .white)
                btn.tag = ToolBarButtonType.MENUS.rawValue
                btn.backgroundColor = ConstFile.gloab_repost_bg_color
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            case .PROFILE:
                
                let proBtn = RaisedButton(image: Icon.home, tintColor: .white)
                proBtn.tag = ToolBarButtonType.PROFILE.rawValue
                proBtn.backgroundColor = ConstFile.gloab_repost_bg_color
                proBtn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(proBtn)
                
                proBtn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            case .SCROLLTOTOP:
                 
                 let proBtn = RaisedButton(image: Icon.home, tintColor: .white)
                 proBtn.tag = ToolBarButtonType.SCROLLTOTOP.rawValue
                 proBtn.backgroundColor = ConstFile.gloab_repost_bg_color
                proBtn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(proBtn)
                
                proBtn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            default:
                let btn = BottomToolBarView.ButtonHas(title: nil, img: Icon.bell, tag: ToolBarButtonType.MORE.rawValue)
                btn.addTarget(self, action: #selector(typeButtonClick(sender:)), for: .touchUpInside)
                self.layoutStackView.addArrangedSubview(btn)
                
                btn.snp.makeConstraints { (make) in
                    make.height.equalTo(h)
                    make.width.equalTo(btnW)
                }
            }
        }
    }

    
    // 出现方法
    func show(inView: UIView){
        
        // 没有按钮就不弹出
        if self.layoutStackView == nil || self.layoutStackView.subviews.count == 0 {
            return
        }
        
        let h:CGFloat = ConstFile.bottomToolBarHeight
        let frame = CGRect(x: 0,y: h,width: ConstFile.ScreenW,height: h)
        self.frame = frame
        
        inView.addSubview(self)
    
        UIView.animate(withDuration: 0.15) {

            var frame = self.frame
            frame.origin.y -= ConstFile.bottomToolBarHeight//((ConstFile.bottomToolBarHeight + 44 + UIApplication.shared.statusBarFrame.size.height))

            self.frame = frame
        }
        inView.bringSubviewToFront(self)
    }
    
    // 隐藏方法
    func hide(){
        
        UIView.animate(withDuration: 0.15, animations: {
            var frame = self.frame
            frame.origin.y += 100
            self.frame = frame
        }) { (bol) in
            self.removeFromSuperview()
            
        }
    }
    
    static func ButtonHas(title: String?, img: UIImage?, tag: Int)->UIButton{
        let btn = FlatButton(type: .custom)//UIButton(type: .custom)
        if title != nil {
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitleColor(UIColor.white, for: .normal)
        }
        if img != nil {
            let image = img?.withRenderingMode(.alwaysOriginal)
            btn.setImage(image, for: .normal)
        }
        
        btn.tag = tag
        
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 16
        
        return btn
    }
    
    @objc func typeButtonClick(sender: UIButton){
        
        switch sender.tag {
        case ToolBarButtonType.BACK.rawValue:
            self.delegate?.backButtonClick!()
        case ToolBarButtonType.SEARCH.rawValue:
            self.delegate?.searchButtonClick?()
        case ToolBarButtonType.SETTING.rawValue:
            self.delegate?.settingButtonClick!()
        case ToolBarButtonType.ADD.rawValue:
            self.delegate?.addButtonClick!()
        case ToolBarButtonType.MENUS.rawValue:
            self.delegate?.menusButtonClick!()
        case ToolBarButtonType.PROFILE.rawValue:
            self.delegate?.profileButtonClick?()
        case ToolBarButtonType.EDIT.rawValue:
            self.delegate?.editButtonClick?()
        case ToolBarButtonType.LINKTOWEIBO.rawValue:
            self.delegate?.linketoweiboButtonClick?()
        case ToolBarButtonType.KEEP.rawValue:
            self.delegate?.keepButtonClick?()
        case ToolBarButtonType.SCROLLTOTOP.rawValue:
            self.delegate?.scrolltotopButtonClick?()
        default:
            self.delegate?.moreButtonClick!()
            
        }
    }
    
}
