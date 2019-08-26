//
//  MTAlertView.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/21.
//

import UIKit
import Foundation
import SnapKit
import Material

/// 类型区分 顶部 中间 底部 弹出
enum MTAlertViewType {
    case top
    case mid
    case bottom
}

// 按钮点击代理
@objc protocol MTAlertViewDelegate {
     @objc optional func commitBtnClick(sender: UIButton)
    @objc optional func logoutBtnClick()
}

/// Metro 风格的弹出视图 根据类型区分 顶部 中间 底部 弹出
class MTAlertView: UIView {

    // 标题
    lazy var titleLable = UILabel()
    // 内容框
    lazy var contentTextView = UITextView()
    // 操作按钮
    lazy var actionButtons = [MTButton]()
    // 类型 默认顶部
    var type = MTAlertViewType.top
    // 确认按钮 不管是何种状态 必须包含一个默认按钮  单独的文字提示请使用 HUD 展示
    lazy var commitButton = RaisedButton(title: "确认", titleColor: Color.red.darken3)
    lazy var cancelButton = RaisedButton(title: "取消", titleColor: .white)
    lazy var logoutButton = RaisedButton(title: "退出登录", titleColor: Color.red.darken3)
    // switch
    lazy var autoPlay = Switch(state: .off, size: .custom(width: 40, height: 30))
    // 背景图
    lazy var alertBGView = UIView()
    // 代理
    var delegate: MTAlertViewDelegate?
    // 背景图
    var alertView:UIView = UIView()
    
    // life
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    
    /// 初始化方法 通过addAction(button: MTButton...) 来增加按钮
    ///
    /// - Parameters:
    ///
    ///   - content: 内容
    ///   - type: 类型 暂时没用
    init() {
        
        
        let defaultFrame = CGRect(x: 0, y: 0, width: ConstFile.ScreenW, height: ConstFile.ScreenH)
        super.init(frame: defaultFrame)
    }
   
}

/// UI 相关
extension MTAlertView: SwitchDelegate {
    
    /// 默认布局
    func  okShow(msg: String) {
        
        self.contentTextView.text = msg
        
        let bottomLineColor = ConstFile.status_high_color//UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1)
        let margin:CGFloat = 20
        let btnW :CGFloat = (ConstFile.ScreenW - 4 * margin - 10) * 0.5
        let bgColor = ConstFile.gloab_repost_bg_color
        self.alertBGView.backgroundColor = ConstFile.gloab_bg_color
        
        // 布局弹出视图
        self.commitButton.backgroundColor = bgColor
        self.commitButton.layer.borderWidth = 0
        self.commitButton.addTarget(self, action: #selector(doneBtnClick(sender:)), for: .touchUpInside)
        self.alertBGView.addSubview(self.commitButton)
        
        self.commitButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(2*margin)
            make.bottom.equalToSuperview().offset(-margin)
            make.width.equalTo(btnW)
        }
        
        self.cancelButton.backgroundColor = bgColor
        self.cancelButton.layer.borderWidth = 0
        self.cancelButton.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        self.alertBGView.addSubview(self.cancelButton)
        
        self.cancelButton.snp.makeConstraints { (make) in
            
            make.right.equalToSuperview().offset(-2*margin)
            make.bottom.equalToSuperview().offset(-margin)
            make.width.equalTo(btnW)
        }
        
        // 提示内容
        self.contentTextView.textColor = UIColor.white
        self.contentTextView.backgroundColor = UIColor.clear
        self.contentTextView.textAlignment = .left
        self.contentTextView.isEditable = false
        
        self.contentTextView.font = UIFont.systemFont(ofSize: 18, weight: .bold)//systemFont(ofSize: 18)
        self.alertBGView.addSubview(self.contentTextView)
        
        self.contentTextView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.commitButton.snp_top).offset(-margin)
            make.left.equalToSuperview().offset(2*margin)
            make.right.equalToSuperview().offset(-2*margin)
            make.height.equalTo(60)
        }
        
        // 底部分割线
        let lineView = UIView()
        lineView.backgroundColor = bottomLineColor
        self.alertBGView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // 弹出容器视图
        self.addSubview(self.alertBGView)
        self.alertBGView.snp.makeConstraints { (make) in
            
            make.top.left.right.equalToSuperview()
            make.height.equalTo(160)
        }
        
        show()
    }
    
    /// 设置提示菜单
    func settingShow(){
        
        let bottomLineColor = ConstFile.status_high_color//UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1)
        let margin:CGFloat = 20
        let btnW :CGFloat = (ConstFile.ScreenW - 4 * margin - 10)
        let bgColor = ConstFile.gloab_repost_bg_color
        self.alertBGView.backgroundColor = ConstFile.gloab_bg_color
        
        // 关闭按钮
        let close = RaisedButton(title: "关闭", titleColor: .white)
        close.backgroundColor = bgColor
        close.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        self.alertBGView.addSubview(close)
        
        close.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(btnW)
        }
        
        // 布局弹出视图
        self.logoutButton.backgroundColor = bgColor
        self.logoutButton.layer.borderWidth = 0
        self.logoutButton.addTarget(self, action: #selector(logoutBtnClick), for: .touchUpInside)
        self.alertBGView.addSubview(self.logoutButton)
        
        self.logoutButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(close.snp_top).offset(-margin)
            make.width.equalTo(btnW)
        }
        
        // e个人主页
        let profile = RaisedButton(title: "个人主页", titleColor: .white)
        profile.backgroundColor = bgColor
        profile.addTarget(self, action: #selector(profileBtnClick), for: .touchUpInside)
        self.alertBGView.addSubview(profile)
        
        profile.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.logoutButton.snp_top).offset(-margin)
            make.width.equalTo(btnW)
        }
        
        // 提示内容
        self.contentTextView.text = "wifi下自动播放视频"
        self.contentTextView.textColor = UIColor.white
        self.contentTextView.backgroundColor = UIColor.clear
        self.contentTextView.textAlignment = .left
        self.contentTextView.isEditable = false
        self.contentTextView.font = UIFont.systemFont(ofSize: 16, weight: .bold)//systemFont(ofSize: 18)
        
        self.alertBGView.addSubview(self.contentTextView)
        
        self.contentTextView.snp.makeConstraints { (make) in
            make.bottom.equalTo(profile.snp_top).offset(-margin)
            make.left.equalToSuperview().offset(2*margin)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        
        // 滑块
        self.autoPlay.delegate = self
        self.autoPlay.buttonOnColor = Color.blue.darken2
        self.autoPlay.buttonOffColor = Color.grey.lighten1
        self.autoPlay.trackOnColor = Color.blue.lighten1
        self.autoPlay.trackOffColor = Color.grey.darken3
        self.autoPlay.isOn = UserDefaults.standard.value(forKey: ConstFile.auto_play_userdefault) as! Bool

        self.alertBGView.addSubview(self.autoPlay)
        self.autoPlay.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.logoutButton.snp_top).offset(-1*margin)
            make.centerY.equalTo(self.contentTextView)
            make.right.equalToSuperview().offset(-2*margin)
            
        }
        
        // 底部分割线
        let lineView = UIView()
        lineView.backgroundColor = bottomLineColor
        self.alertBGView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // 弹出容器视图
        self.addSubview(self.alertBGView)
        self.alertBGView.snp.makeConstraints { (make) in
            
            make.top.left.right.equalToSuperview()
            make.height.equalTo(250)
        }
        
        show()
    }
    
    func switchDidChangeState(control: Switch, state: SwitchState) {
        let flag:Bool = state == .off ? false : true
        UserDefaults.standard.set(flag, forKey: ConstFile.auto_play_userdefault)
    }
    
}

/// 弹出白色半透明的提示框
extension MTAlertView {
    
    // 顶部加载小点
    func showProcess(msg: String){
        
        // 白色透明背景图
        alertView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        
        // 转转的菊花
        let juhua = UIActivityIndicatorView(style: .gray)
        juhua.startAnimating()
        alertView.addSubview(juhua)
        
        juhua.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        // 提示文字
        let textLable = UILabel()
        textLable.text = msg//"哇呜~哇呜~"
        textLable.textColor = UIColor.black
        textLable.font = ConstFile.status_text_font
        textLable.textAlignment = .center
        textLable.sizeToFit()
        alertView.addSubview(textLable)
        
        textLable.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(juhua.snp.right).offset(10)
        }
        
        // 初始化frame
        var frame = textLable.frame
        frame.size.width += 70
        frame.size.height = 34
        frame.origin.x = (ConstFile.ScreenW - frame.size.width)/2
        frame.origin.y = -45
        alertView.frame = frame
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 4
        
        // 动画加载
        UIApplication.shared.keyWindow?.addSubview(alertView)
        showPro()
        
    }
    // 弹出选择框
    private func showPro(){
        
        UIView.animate(withDuration: 0.25, animations: {
            
            var frame = self.alertView.frame
            frame.origin.y = ConstFile.StatusBarH + 5
            self.alertView.frame = frame
            
        })
    }
    // 关闭选择框
    private func hidePro(){
        
        UIView.animate(withDuration: 0.25, delay: 1, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            
            var frame = self.alertView.frame
            frame.origin.y = -45
            self.alertView.frame = frame
            
        }, completion: { (falg) in
            self.alertView.removeFromSuperview()
        })
    }
    // 关闭选择框
    func hideForPro(){
        hidePro()
    }
    // 顶部弹出提示文字
    func showInfo(msg: String, inview: UIView?, duration: TimeInterval, alignment: NSTextAlignment = .center){
        
        let textLable = UILabel()
        textLable.text = msg
        textLable.textColor = UIColor.black
        textLable.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        
        textLable.font = ConstFile.status_text_font
        textLable.clipsToBounds = true
        textLable.textAlignment = .center
        textLable.sizeToFit()
        
        var frame = textLable.frame
        frame.size.width += 40
        frame.size.height = 34
        frame.origin.x = (ConstFile.ScreenW - frame.size.width)/2
        frame.origin.y = -45
        textLable.frame = frame
        textLable.layer.cornerRadius = 4
        
        if inview != nil {
            inview!.addSubview(textLable)
        }else {
            UIApplication.shared.keyWindow?.addSubview(textLable)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            
            var frame = textLable.frame
            frame.origin.y = inview == nil ? ConstFile.StatusBarH + 5 : 5
            textLable.frame = frame
            
        }, completion: { (flag) in
            
            UIView.animate(withDuration: 0.25, delay: duration, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                
                var frame = textLable.frame
                frame.origin.y = -45
                textLable.frame = frame
                
            }, completion: { (falg) in
                textLable.removeFromSuperview()
            })
            
        })
        //        }
        
    }
    
}


/// 弹出带有取消和确认按钮的提示框
extension MTAlertView {
    
    @objc func profileBtnClick(){
        hide()
        WeiboSDK.linkToProfile()
    }
    
    @objc func logoutBtnClick(){
        self.delegate?.logoutBtnClick!()
        hide()
       
    }
    
    @objc func closeBtnClick(){
        hide()
    }
    
    @objc func cancelBtnClick(){
        hide()
    }
    
    @objc func doneBtnClick(sender: UIButton){
        self.delegate?.commitBtnClick!(sender: sender)
        hide()
    }
    
    func show(){
    
        var frame = self.frame
        frame.origin.y = -frame.size.height
        self.frame = frame
        let keyv = UIApplication.shared.keyWindow
    
        keyv?.addSubview(self)
        
        UIView.animate(withDuration: 0.35, animations: {
            var frame = self.frame
            frame.origin.y = 0
            self.frame = frame
        }) { (b) in
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        }
    }
    
    func hide(){
        
        self.backgroundColor = UIColor.clear
        
        UIView.animate(withDuration: 0.35, animations: {
            var frame = self.frame
            frame.origin.y = -frame.size.height
            self.frame = frame
        }) { (b) in
            self.removeFromSuperview()
        }
       
    }
}
