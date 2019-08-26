//
//  ATMERepostView_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import SnapKit
import Kingfisher
import YYText

import AVFoundation
import AsyncDisplayKit


/// @我的微博cell视图
class ATMERepostView_ASDK: ASDisplayNode {
    
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
    // 背景图
    let lineView = ASDisplayNode()
    

    init(model: StatusModel) {
        super.init()
        
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        // 自动管理node
        automaticallyManagesSubnodes = true
        self.lineView.backgroundColor = ConstFile.gloab_repost_bg_color//Color.grey.darken3//
//        DispatchQueue.main.async {
//            self.lineView.layer.shadowRadius = 4
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
        // 日期
        let dateAttr = model.createAtTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 10, weight: .regular), color: UIColor.lightGray, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.dateTimeLable.attributedText = dateAttr
       
        // 评论内容
        var attributeString = model.textString.attributesStringWith(font: ConstFile.status_repost_text_font, color: ConstFile.gloab_sub_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        
        let tuple = RichTxtTool.setupAttributestring(m: model, attributeString: attributeString)
        let txt = tuple.0
        //        self.videoModel = tuple.2
        attributeString = tuple.1
        
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_repost_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        // 增加高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: false, font: ConstFile.status_repost_text_font, specTxt:txt)
        
         self.conentTextView.attributedText = attributeString
        
        
    }
    
    
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.avatarImageView.style.preferredSize = CGSize(width: 34, height: 34)
        
        // 名字与日期
        let nameAndDateSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [self.screenNameLable, self.dateTimeLable])
        
        // 头像与 名字 日期
        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.avatarImageView, nameAndDateSpec])
        
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,left: 44,bottom: 0,right: 10), child: self.conentTextView)
        
        
        let childsSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [topSpec, textSpec])
        
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: childsSpec)
        let bgs = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10), child: self.lineView)
        let bgspec = ASBackgroundLayoutSpec(child: resultSpec, background: bgs)
        return bgspec
    }
    
    
}
