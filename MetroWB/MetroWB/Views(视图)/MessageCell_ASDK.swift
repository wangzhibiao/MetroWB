//
//  MessageCell_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/9.
//

import UIKit
import AsyncDisplayKit
import YYText
import Material

/// 使用AsyncDisplayKit 优化cell
class MessageCell_ASDK: ASCellNode {
    
    // 昵称
    let screenNameLable = ASTextNode()
    
    // 提示内容
    let conentTextView = ASTextNode()
    
    
    init(title: String, subTitle: String) {
        super.init()
        
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        // 自动管理node
        automaticallyManagesSubnodes = true
        
    
        // 名字
        let nameAttr = title.attributesStringWith(font: UIFont.systemFont(ofSize: 20, weight: .bold), color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.screenNameLable.attributedText = nameAttr
       
        // 评论内容
        let attributeString = subTitle.attributesStringWith(font: UIFont.systemFont(ofSize: 13, weight: .regular), color: ConstFile.gloab_sub_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        self.conentTextView.attributedText = attributeString
    }
    
    
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // 标题
        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [self.screenNameLable])
        
        // 副标题
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10,left: 10,bottom: 0,right: 10), child: self.conentTextView)
        
        let childsSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [topSpec, textSpec])
        
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: childsSpec)
        return resultSpec
    }
    
    
}
