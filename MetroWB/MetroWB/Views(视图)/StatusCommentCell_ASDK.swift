//
//  StatusCommentCell_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/31.
//

import UIKit
import AsyncDisplayKit
import YYText
import Material


protocol StatusCommentCell_ASDKDelegate {
    func delButtonClick(model: StatusCommentModel)
}

/// 使用AsyncDisplayKit 优化评论cell
class StatusCommentCell_ASDK: ASCellNode {

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
    // 微博内容
    let conentTextView = ASTextNode()
    // 回复条数 如果有就显示
    let replyNumLable = ASTextNode()
    
    // 删除按钮 如果评论是自己发布的可以删除
    let delButton = ASButtonNode()
    // 背景图
    let lineView = ASDisplayNode()
    
    var delegate: StatusCommentCell_ASDKDelegate?
    var model:StatusCommentModel!
   
    init(model: StatusCommentModel) {
        super.init()
        
        self.model = model
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        // 自动管理node
        automaticallyManagesSubnodes = true
        self.lineView.backgroundColor = ConstFile.gloab_bg_color//Color.grey.darken3//
//        DispatchQueue.main.async {
//            self.lineView.layer.shadowRadius = 4
//            self.lineView.layer.shadowColor = UIColor.gray.cgColor
//            self.lineView.layer.shadowOpacity = 0.5
//            self.lineView.layer.shadowOffset = CGSize(width: 1, height: 0)
//
//        }
        // 头像
        self.avatarImageView.url = URL(string: model.user.avatar_large!)
        // 名字
        let nameAttr = model.user.screen_name!.attributesStringWith(font: UIFont.systemFont(ofSize: 14, weight: .regular), color: ConstFile.gloab_sub_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.screenNameLable.attributedText = nameAttr
        // 日期
         let dateAttr = model.createAtTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 10, weight: .regular), color: ConstFile.gloab_sub_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.dateTimeLable.attributedText = dateAttr
        // 评论内容
        let str = model.text!
        let attribute = EmoticonTools.shared.emoctionString(str: str, font: ConstFile.status_repost_text_font)
        
        var attributeString = attribute.attributesStringWith(font: ConstFile.status_repost_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        // 高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: str.hasSuffix("全文"),font: ConstFile.status_repost_text_font)
      
        self.conentTextView.attributedText = attributeString
        
        // 删除评论
        self.delButton.setTitle("删除", with: ConstFile.status_text_font, with: ConstFile.status_high_color, for: .normal)
        //attributedText = "删除".attributesStringWith(font: ConstFile.status_repost_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.delButton.borderColor = ConstFile.gloab_font_color.cgColor
        self.delButton.borderWidth = 1
        self.delButton.cornerRadius = 2
        self.delButton.isHidden = !(model.user.id == MTNetWorkTools.shared.userAccess.id)
        self.delButton.addTarget(self, action: #selector(delBtnClick), forControlEvents: .touchUpInside)
        
        // 分割线
        self.lineView.backgroundColor = ConstFile.gloab_repost_bg_color
    
    }
    
    @objc func delBtnClick(){
        
        self.delegate?.delButtonClick(model: self.model)
    }
   
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.avatarImageView.style.preferredSize = CGSize(width: 35, height: 35)
        self.delButton.style.preferredSize = CGSize(width: 50, height: 30)
        // 名字与日期
        let nameAndDateSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [self.screenNameLable, self.dateTimeLable])
        
        let leftImgNameSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .start, children: [self.avatarImageView, nameAndDateSpec])
        // 删除按钮
         let rightSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: ASStackLayoutJustifyContent.center, alignItems: .end, children: [self.delButton])
        // 头像与 名字 日期
        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween, alignItems: .stretch, children: [leftImgNameSpec, rightSpec])
        
//        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .spaceBetween, alignItems: .stretch, children: [leftImgNameSpec, self.dateTimeLable])
        
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10,left: 44,bottom: 0,right: 10), child: self.conentTextView)
        
        self.lineView.style.preferredSize = CGSize(width: UIScreen.main.bounds.width-54, height: 1)
        let lineSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0), child: self.lineView)
        
        let childsSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [topSpec, textSpec, lineSpec])
        
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: childsSpec)
//        let bgs = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10), child: self.lineView)
//        let bgspec = ASBackgroundLayoutSpec(child: resultSpec, background: bgs)
        return resultSpec
    }
    

}
