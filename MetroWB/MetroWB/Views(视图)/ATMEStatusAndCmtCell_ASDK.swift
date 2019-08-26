//
//  ATMEStatusAndCmtCell_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import AsyncDisplayKit
import YYText
import Material


/// 回复按钮代理
protocol ATMEStatusAndCmtCell_ASDKDelegate {
    func replyButtonClick(model: StatusCommentModel)
}



/// 使用AsyncDisplayKit 优化评论cell
class ATMEStatusAndCmtCell_ASDK: ASCellNode {
    
    // 头像
    let avatarImageView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 昵称
    let screenNameLable = ASTextNode()
    
    // 日期
    let dateTimeLable = ASTextNode()
    // 来源
    var sourceLable = ASTextNode()
    // 微博内容
    let conentTextView = ASTextNode()
    
    // 转发的背景图
    let bgView = ASDisplayNode()
    // 转发头像
    let repostAvatarImgView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 转发昵称
     let repostScreenNameLable = ASTextNode()
    // 转发内容
     let repostConentTextView = ASTextNode()
    
    // 背景图
    var bgShowView = ASDisplayNode()
    // 背景图
    let lineView = ASDisplayNode()
    
    // 回复按钮
    let replyButton = ASButtonNode()
    
    var delegate: ATMEStatusAndCmtCell_ASDKDelegate?
    
    var model:StatusCommentModel?
    
    init(model: StatusCommentModel) {
        super.init()
        self.model = model
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        
        // 自动管理node
        automaticallyManagesSubnodes = true
//        self.lineView.backgroundColor = ConstFile.gloab_bg_color//Color.grey.darken3//
//        DispatchQueue.main.async {
//            self.lineView.layer.shadowRadius = 3
//            self.lineView.layer.shadowColor = UIColor.gray.cgColor
//            self.lineView.layer.shadowOpacity = 0.5
//            self.lineView.layer.shadowOffset = CGSize(width: 1, height: 0)
            
//        }
        
        if model.user != nil {
            // 头像
            self.avatarImageView.url = URL(string: model.user!.avatar_large!)
            // 名字
            let nameAttr = model.user!.screen_name!.attributesStringWith(font: UIFont.systemFont(ofSize: 18, weight: .bold), color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
            self.screenNameLable.attributedText = nameAttr
        }
        
        // 正文
        // 转成 NSMutableAttributedString
        var attributeString = model.text.attributesStringWith(font: ConstFile.status_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        // 替换链接 视频或网页链接
//        let tuple = RichTxtTool.setupAttributestring(m: model, attributeString: attributeString)
//        let txt = tuple.0
//        self.videoModel = tuple.2
//        attributeString = tuple.1
        
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        // 增加高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: false, font: ConstFile.status_text_font, specTxt: [])
        
        self.conentTextView.attributedText = attributeString
        self.conentTextView.isUserInteractionEnabled = false
        
        self.bgShowView = ATMERepostView_ASDK(model: model.status)
        
        // 日期
        let dateAttr = model.createAtTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.dateTimeLable.attributedText = dateAttr
        
        // 来源
        let srcAttr = model.sourceTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.sourceLable.attributedText = srcAttr
        
        // 删除评论
        self.replyButton.setTitle("回复", with: ConstFile.status_text_font, with: ConstFile.status_high_color, for: .normal)
        //attributedText = "删除".attributesStringWith(font: ConstFile.status_repost_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.replyButton.borderColor = ConstFile.gloab_font_color.cgColor
        self.replyButton.borderWidth = 1
        self.replyButton.cornerRadius = 2
        self.replyButton.addTarget(self, action: #selector(replyClick), forControlEvents: .touchUpInside)
        
        
        // 分割线
        self.lineView.backgroundColor = ConstFile.gloab_repost_bg_color
    }
    
    var statusM: StatusModel?
    init(model: StatusModel) {
        super.init()
        self.statusM = model
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        
        // 自动管理node
        automaticallyManagesSubnodes = true
        self.lineView.backgroundColor = ConstFile.gloab_repost_bg_color//Color.grey.darken3//
//        DispatchQueue.main.async {
//            self.lineView.layer.shadowRadius = 3
//            self.lineView.layer.shadowColor = UIColor.gray.cgColor
//            self.lineView.layer.shadowOpacity = 0.5
//            self.lineView.layer.shadowOffset = CGSize(width: 1, height: 0)
//
//        }
        
        if model.user != nil {
            // 头像
            self.avatarImageView.url = URL(string: model.user!.avatar_large!)
            // 名字
            let nameAttr = model.user!.screen_name!.attributesStringWith(font: UIFont.systemFont(ofSize: 18, weight: .bold), color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
            self.screenNameLable.attributedText = nameAttr
        }
        
        // 正文
        // 转成 NSMutableAttributedString
        var attributeString = model.textString.attributesStringWith(font: ConstFile.status_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        // 替换链接 视频或网页链接
        let tuple = RichTxtTool.setupAttributestring(m: model, attributeString: attributeString)
        let txt = tuple.0
//        self.videoModel = tuple.2
        attributeString = tuple.1
        
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        // 增加高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: false, font: ConstFile.status_text_font, specTxt:txt)
        
        self.conentTextView.attributedText = attributeString
        self.conentTextView.isUserInteractionEnabled = false
        
        self.bgShowView = ATMERepostView_ASDK(model: model.retweeted_status!)
        
        // 日期
        let dateAttr = model.createAtTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.dateTimeLable.attributedText = dateAttr
        
        // 来源
        let srcAttr = model.sourceTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.sourceLable.attributedText = srcAttr
        
    }
 
    @objc func replyClick(){
        self.delegate?.replyButtonClick(model: self.model!)
    }
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.avatarImageView.style.preferredSize = CGSize(width: 34, height: 34)
        self.replyButton.style.preferredSize = CGSize(width: 50, height: 30)
        // 名字与日期
        let nameAndDateSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [self.screenNameLable, self.dateTimeLable])
        
        let leftImgNameSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .start, children: [self.avatarImageView, nameAndDateSpec])
        // 删除按钮
        let rightSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: ASStackLayoutJustifyContent.center, alignItems: .end, children: [self.replyButton])
        
        // 头像与 名字 日期
        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween, alignItems: .stretch, children: [leftImgNameSpec, rightSpec])
        
        
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10,left: 44,bottom: 0,right: 10), child: self.conentTextView)
        
        let bgShowSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,left: 34,bottom: 0,right: 0), child: self.bgShowView)
        
        self.lineView.style.preferredSize = CGSize(width: UIScreen.main.bounds.width-54, height: 1)
        let lineSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0), child: self.lineView)
        
        let childsSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [topSpec, textSpec, bgShowSpec, lineSpec])
        
      
        
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: childsSpec)
//        let bgs = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10), child: self.lineView)
//        let bgspec = ASBackgroundLayoutSpec(child: resultSpec, background: bgs)
        return resultSpec
    }
    
    
}
