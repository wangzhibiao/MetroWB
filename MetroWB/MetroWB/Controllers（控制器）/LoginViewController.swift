//
//  LoginViewController.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/24.
//

import UIKit
import SnapKit
//import SwiftEntryKit
//import NVActivityIndicatorView

// 登录授权控制器
class LoginViewController: BaseViewController {

    lazy var loginBtn = UIButton(type: .custom)
    var btnColor = UIColor(red: 135/255, green: 206/255, blue: 250/250, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 初始化页面
    func setupUI(){
        
        // 介绍文字
        let lable = UILabel()
        lable.text = "圆滑当道时代的异类"
        lable.textColor = btnColor//135,206,250
        lable.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        lable.textAlignment = .center
        lable.numberOfLines = 0
    
        self.view.addSubview(lable)
        
        lable.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalTo(ConstFile.ScreenW-20)
//            make.height.equalTo(80)
        }
        
        //\nWeibo for Metro UI
        let sblable = UILabel()
        sblable.text = "Weibo of Metro UI"
        sblable.textColor = btnColor//135,206,250
        sblable.font = UIFont.systemFont(ofSize: 22, weight: .light)
        sblable.textAlignment = .center
        sblable.numberOfLines = 0
        
        self.view.addSubview(sblable)
        
        sblable.snp.makeConstraints { (make) in
            
            make.top.equalTo(lable.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(ConstFile.ScreenW-20)
//            make.height.equalTo(80)
        }
        
        // 登录按钮
        loginBtn = UIButton(type: .custom)
        loginBtn.backgroundColor = btnColor
        loginBtn.setTitle("开始", for: .normal)
        loginBtn.setTitleColor(UIColor.white, for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.view.addSubview(loginBtn)
        
        // 初始位置
        loginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
            make.width.equalTo(ConstFile.ScreenW-80)
            make.height.equalTo(44)
        }
        
        // 各个点击事件监听
        loginBtn.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
        loginBtn.addTarget(self, action: #selector(loginBtnDown(sender:)), for: .touchDown)
        loginBtn.addTarget(self, action: #selector(loginBtnCancel(sender:)), for: .touchCancel)
        loginBtn.addTarget(self, action: #selector(loginBtnOutside(sender:)), for: .touchUpOutside)
    }
   
    // 调用微博授权界面
    @objc func loginBtnClick(){
        resetBtn()

        let request = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = ConstFile.AouthUrl
        request.scope = "all"
        
        WeiboSDK.send(request)
    
    }
    
    // 设置按下效果
    @objc func loginBtnDown(sender: UIButton){
        
        sender.backgroundColor = UIColor.white
        sender.setTitleColor(ConstFile.gloab_bg_color, for: .normal)
        sender.layer.borderColor = ConstFile.gloab_bg_color.cgColor
        sender.layer.borderWidth = 1
    }
    // 取消按下
    @objc func loginBtnCancel(sender: UIButton){
       resetBtn()
    }
    // outside
    @objc func loginBtnOutside(sender: UIButton){
        resetBtn()
    }
    
    // 重置按钮
    func resetBtn(){
        loginBtn.backgroundColor = btnColor
        loginBtn.setTitleColor(UIColor.white, for: .normal)
        loginBtn.layer.borderColor = ConstFile.gloab_bg_color.cgColor
        loginBtn.layer.borderWidth = 0
    }

}
