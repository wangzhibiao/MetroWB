//
//  BaseTextEditorVC.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/24.
//

import UIKit
import SnapKit
import Material

/// 输入框确认代理方法
protocol BaseTextEditorVCDelegate {
    func commitSend(txt: String)
}



/// 基础文字输入框控制器 发表微博评论等使用
class BaseTextEditorVC: UIViewController {

    // 输入框
    var textField:UITextView?
    // 占位符
    var placeHolderStr:String?
    /// 占位lable
    lazy var placeLable = UILabel()
    // 标题
    var titleStr:String?
    /// 输入框工具条
    var toolBarView: KeyBoardToolBarView!
    var delegate: BaseTextEditorVCDelegate?
    
    init(placeHolder: String, title: String){
        super.init(nibName: nil, bundle: nil)
        self.placeHolderStr = placeHolder
        self.titleStr = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 监听键盘弹出消失
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(ntf:)), name: UIResponder.keyboardDidShowNotification, object: nil)
//         NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(ntf:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    // 取消通知监听
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    
}

/// UI相关
extension BaseTextEditorVC {
    
    func setupUI(){
        
        self.view.backgroundColor = ConstFile.gloab_bg_color
        // 设置键盘共具条
        setupKeyboardToolBar()
        
        self.textField = UITextView()
        self.textField?.font = ConstFile.status_text_font
        self.textField?.tintColor = ConstFile.gloab_sub_font_color
        self.textField?.backgroundColor = ConstFile.gloab_repost_bg_color
        self.textField?.delegate = self
        self.textField?.textColor = ConstFile.gloab_font_color
        self.textField?.inputAccessoryView = self.toolBarView
        self.view.addSubview(self.textField!)
        
        self.textField?.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(10)
             make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(200)
        })
        
        self.textField?.becomeFirstResponder()
        
        // 设置占位符
        setupPlaceHodler()
        // 设置标题
        setupNavTitle()
       
    }
    
    /// 设置键盘共具条
    private func setupKeyboardToolBar(){
        
        let frame = CGRect(x: 0, y: ConstFile.ScreenH, width: ConstFile.ScreenW, height: 44)
        self.toolBarView = KeyBoardToolBarView(frame: frame)
        self.toolBarView.delegate = self
    }
    
    /// 设置占位文字
    private func setupPlaceHodler(){
        
        self.placeLable.textColor = ConstFile.gloab_sub_font_color
        self.placeLable.font = ConstFile.status_text_font
        self.placeLable.text = self.placeHolderStr
        self.textField?.addSubview(self.placeLable)
        
        self.placeLable.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(7)
        }
    }
    
    ///  设置标题
    private func setupNavTitle(){
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        let imgv = UIImageView(frame: CGRect(x: -5, y: 10, width: 34, height: 34))
        imgv.clipsToBounds = true
        
        if MTNetWorkTools.shared.userAccess.id != 0 {
            let url = URL(string: MTNetWorkTools.shared.userAccess.avatar_large ?? "")
            imgv.kf.setImage(with: url, placeholder: UIImage(named: "default_user"))
            
            leftView.addSubview(imgv)
        }
        
        
        let txtV = UILabel(frame: CGRect(x: 34, y: 10, width: 200, height: 34))
        txtV.text = self.titleStr
        txtV.textColor = ConstFile.gloab_font_color
        txtV.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        leftView.addSubview(txtV)
        let leftItem = UIBarButtonItem(customView: leftView)
        self.navigationItem.leftBarButtonItem = leftItem
        
    }
    
    /// 关闭编辑窗口
    @objc private func close(){
        
        self.textField?.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


/// 输入框代理方法分类
/// 监听输入状态 隐藏和显示占位文字 发送事件
extension BaseTextEditorVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeLable.isHidden = textView.text.count > 0
        if textView.text.count > 140 {
            textView.text = textView.text.suffix(140).debugDescription
        }
    }
    
    /// 键盘出现
    @objc func keyboardShow(ntf: Notification){
        
        let userInfo = ntf.userInfo
        let rect = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let y:CGFloat = ConstFile.ScreenH - rect.height - 44
        
        UIView.animate(withDuration: 0.25) {
            
            var frame = self.toolBarView.frame
            frame.origin.y = y
            self.toolBarView.frame = frame
            
        }
        
    }
    
    /// 键盘消失
    @objc func keyboardHide(ntf: Notification){
        
        UIView.animate(withDuration: 0.25) {
            
            var frame = self.toolBarView.frame
            frame.origin.y = ConstFile.ScreenH
            self.toolBarView.frame = frame
            
        }
    }

}

/// 共具条代理方法
extension BaseTextEditorVC: KeyBoardToolBarViewDelegate {
    
    func typeButtonClick(button: UIButton) {
        
        switch button.tag {
        case KEYTYPE.AT.hashValue:
            print("@ clifk")
        case KEYTYPE.TAG.hashValue:
           print("@ clifk")
        case KEYTYPE.PHOTO.hashValue:
           print("@ clifk")
        case KEYTYPE.CLOSE.hashValue:
           self.close()
        case KEYTYPE.SEND.hashValue:
           
            let msg = self.textField?.text
            if msg?.count == 0 {
                MTAlertView().showInfo(msg: "内容不能为空", inview: nil, duration: 2)
                
            }else {
//                print("the connet is \(msg)")
                self.delegate?.commitSend(txt: msg!)
                self.dismiss(animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
}
