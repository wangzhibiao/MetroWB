//
//  StatusRepostView_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/8/2.
//

import UIKit
import SnapKit
import Kingfisher
import YYText
//import Lightbox
import AVFoundation
import AsyncDisplayKit
//import AXPhotoViewer
//import Nuke
import MobilePlayer
import JXPhotoBrowser
//import Agrume



// 播放按钮闭包
protocol StatusRepostView_ASDKDelegate {
    func statusRepTextClick(indexpath: IndexPath)
    func statusRepUserNameClick(name: String)
    
}

/// 微博cell视图
class StatusRepostView_ASDK: ASDisplayNode {
   
    // indexpath
    var indexPath: IndexPath?
    // 微博内容
    let conentTextView = ASTextNode()
    // 更换texture布局后 九宫格目前先要定义九个图片 用到几个布局几个
    lazy var imgNodeArray = [ASButtonNode]()
    // 视频view
    let videoContentView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 播放按钮
    let palyBtn = ASImageNode()
    // 是否显示全文属性 在详情界面 是要讲内容全部显示出来的
    var isShowAll:Bool = false
    // 视频模型
    var videoModel:ObjectModel?
    
    // 懒加载破放弃
    lazy var player = ASVideoNode()
    // 微博模型
    var model:StatusModel?
    
    var delegate:StatusRepostView_ASDKDelegate?
    
    init(model: StatusModel, idp: IndexPath) {
        super.init()
        self.model = model
        self.indexPath = idp
        // 背景色
        self.backgroundColor = ConstFile.gloab_repost_bg_color
        // 自动管理node
        automaticallyManagesSubnodes = true
       
        // 正文
         var str = ""
        if let user = model.user {
            let name = user.screen_name!
            str = "@" + name + ": "
        }
        str += model.textString
        
        // 转成 NSMutableAttributedString
        var attributeString = attributesStringWith(string: NSMutableAttributedString(string: str), font: ConstFile.status_repost_text_font, color: ConstFile.gloab_sub_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        // 替换链接 视频或网页链接
        let tuple = RichTxtTool.setupAttributestring(m: model, attributeString: attributeString)
        let txt = tuple.0
        self.videoModel = tuple.2
        attributeString = tuple.1
        
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_repost_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        // 增加高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: false, font: ConstFile.status_repost_text_font, specTxt: txt, defaultColor: ConstFile.gloab_sub_font_color)
        self.conentTextView.attributedText = attributeString

        self.conentTextView.delegate = self
        self.conentTextView.addTarget(self, action: #selector(txtClick(txt:)), forControlEvents: .touchUpInside)
        
        // 图片view
        if model.pic_urls != nil && model.pic_urls!.count > 0 {
            setupPics(urls: model.pic_urls!)
        }
        
        // 视频view
        if self.videoModel != nil {
            
            self.player.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            self.player.backgroundColor = UIColor.black
            self.player.contentMode = .scaleAspectFill
            self.player.clipsToBounds = true
            self.player.isUserInteractionEnabled = true
            
            self.player.shouldAutorepeat = true
            self.player.shouldAutoplay = false
            
            let autoplay = UserDefaults.standard.value(forKey: ConstFile.auto_play_userdefault) as! Bool
            if autoplay && MTNetWorkTools.shared.statusStr == .wifi {
                self.player.shouldAutoplay = true
            }
            self.player.muted = true
            
            self.player.url = URL(string: self.videoModel!.image!.url)
            
            var videoUrl = ""
            if self.videoModel?.stream != nil && self.videoModel?.stream.url != nil {
                videoUrl = self.videoModel!.stream!.url!
            }
            else if self.videoModel!.slide_cover != nil {
                videoUrl = self.videoModel!.slide_cover!.slide_videos.first!.url
            }
            
            else if self.videoModel?.urls != nil
                && self.videoModel?.urls?.hevc_mp4_hd != nil {
                videoUrl = self.videoModel!.urls!.hevc_mp4_hd!
            }
            
            let url = URL(string: videoUrl)
            let asset = AVAsset(url: url!)
            DispatchQueue.main.async {
                
                self.player.asset = asset
            }
            self.player.delegate  = self
            
            // 播放按钮
            palyBtn.image = UIImage(named: "status_video_button")
            palyBtn.addTarget(self, action: #selector(playbtnclick(sender:)), forControlEvents: .touchUpInside)
            
        }
    }
    
    func attributesStringWith(string: NSAttributedString,font: UIFont, color: UIColor, kern: NSNumber, lineSpace: CGFloat)-> NSMutableAttributedString{
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace     //设置行间距
        //        paragraphStyle.firstLineHeadIndent = 40     //首行缩进距离
        //        paragraphStyle.headIndent = 50     //文本每一行的缩进距离
        //        paragraphStyle.tailIndent = 20  //文本行末缩进距离
        paragraphStyle.alignment = .justified      //文本对齐方向
        
        let attributeString = NSMutableAttributedString(attributedString: string)
        attributeString.addAttributes([NSAttributedString.Key.font : font], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.kern : kern], range: NSRange(location: 0, length: attributeString.length))
        
        attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
        
        return attributeString
    }
    
    /// 微博内容点击
    @objc func txtClick(txt: ASTextNode){
        
        self.delegate?.statusRepTextClick(indexpath: self.indexPath!)
    }
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // 所有布局数组
        var specArray = [ASLayoutSpec]()
       
        // 详情布局
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0), child: self.conentTextView)
        specArray.append(textSpec)
        
        // 布局图片 注意图片和视频同时存在的情况 只显示图片
        if self.imgNodeArray.count > 0 {
            
            let oneW: CGFloat = ConstFile.ScreenW-40
            let twoW: CGFloat = (ConstFile.ScreenW)/3
            let threeW: CGFloat = (ConstFile.ScreenW-50)/3
            
            switch self.imgNodeArray.count {
            case 1:
                
                let node = self.imgNodeArray.first!
                node.style.preferredSize = CGSize(width: oneW, height: 220)
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [node])
                specArray.append(nodeSpec)
                
            case 2:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: twoW, height: twoW)
                    nodes.append(node)
                }
                
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: nodes)
                specArray.append(nodeSpec)
                
            case 3:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: nodes)
                specArray.append(nodeSpec)
                
            case 4:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: twoW, height: twoW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[0], nodes[1]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[2], nodes[3]])
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [oneSpec, twoSpec])
                
                specArray.append(nodeSpec)
                
            case 5:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[3], nodes[4]])
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec])
                
                specArray.append(nodeSpec)
                
            case 6:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [oneSpec, twoSpec])
                
                specArray.append(nodeSpec)
                
            case 7:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                
                let threeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[6]])
                
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec, threeSpec])
                
                specArray.append(nodeSpec)
            case 8:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                
                let threeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[6],nodes[7]])
                
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec, threeSpec])
                
                specArray.append(nodeSpec)
            case 9:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                
                let threeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [nodes[6],nodes[7],nodes[8]])
                
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .stretch, children: [oneSpec, twoSpec, threeSpec])
                
                specArray.append(nodeSpec)
                
            default:
                break
            }
            
        }else if self.model!.isContentVideo && self.videoModel != nil {
            
            let videoW: CGFloat = ConstFile.ScreenW-50
            if self.model!.isVeritical {
                //
                self.player.style.preferredSize = CGSize(width: videoW*3/4, height: videoW)
                let spec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .center, children: [self.player])
                
                // 播放按钮
                self.palyBtn.style.preferredSize = CGSize(width: 50, height: 50)
                let playSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .init(rawValue: 0), child: self.palyBtn)
                
                let overSpec = ASOverlayLayoutSpec(child: spec, overlay: playSpec)
                specArray.append(overSpec)
                
            }else {
                self.player.style.preferredSize = CGSize(width: videoW, height: videoW*9/16)
                let spec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .start, children: [self.player])
                //                specArray.append(spec)
                // 播放按钮
                self.palyBtn.style.preferredSize = CGSize(width: 50, height: 50)
                let playSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .init(rawValue: 0), child: self.palyBtn)
                let overSpec = ASOverlayLayoutSpec(child: spec, overlay: playSpec)
                specArray.append(overSpec)
            }
            
        }
        
       
        // 所有空间垂直排列
        let allSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: specArray)
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), child: allSpec)
        
        return resultSpec
    }
    
}

//  视频代理控制播放器各个功能
extension StatusRepostView_ASDK: ASVideoNodeDelegate {
    
    
    func didTap(_ videoNode: ASVideoNode) {
        if videoNode.isPlaying() {
            videoNode.pause()
            let url = URL(string: self.videoModel!.stream.hd_url!)
            DispatchQueue.main.async {
                let popVC = MobilePlayerViewController(contentURL: url!)
                
                popVC.title = self.videoModel!.titles == nil ? "" : self.videoModel!.titles[0].title
                popVC.fitVideo()
                UIApplication.shared.keyWindow!.rootViewController!.present(popVC, animated: true, completion: nil)
            }
        }else {
            videoNode.play()
        }
        
    }
    
    func videoNode(_ videoNode: ASVideoNode, didFailToLoadValueForKey key: String, asset: AVAsset, error: Error) {
        MTLog(msg:"视频加载出错了")
    }
    
    func videoNode(_ videoNode: ASVideoNode, willChange state: ASVideoNodePlayerState, to toState: ASVideoNodePlayerState) {
        
        switch toState {
        case .loading:
            MTLog(msg:"视频加载中...")
        case .paused:
            self.palyBtn.isHidden = false
        case .playing:
            self.palyBtn.isHidden = true
        default:
            MTLog(msg:"其他的状态")
        }
    }
    
    @objc func playbtnclick(sender: UIButton){
        self.player.play()
    }
    
    // 九宫格显示照片
    func setupPics(urls: [StatusPicsModel]){
        
        // 无图返回
        if urls.count == 0 {
            return
        }
        
        //  给每张图片赋值
        for i in 0..<9 {
            if i < urls.count {
                
                let img = ASButtonNode { () -> UIView in
                    let v = ImageButton.button(withUrl: urls[i].middlePic!)
                    v.tag = i
                    v.addTarget(self, action: #selector(self.previewPhotos(button:)), for: .touchUpInside)
                    return v
                }
                
                img.addTarget(self, action: #selector(previewPhotos(button:)), forControlEvents: .touchUpInside)
                self.imgNodeArray.append(img)
            }
        }
    }
    
    // 照片点击预览
    @objc func previewPhotos(button: UIButton){
        
//        var urls = [String]()
//        for url in self.model!.pic_urls! {
//            //            let u = URL(string: url.middlePic!)!
//            urls.append(url.middlePic!)
//            
//            MTLog(msg: "图片地址: \(url.middlePic!)")
//        }
//        
//        let loader = JXKingfisherLoader()
//        let src = JXRawImageDataSource(photoLoader: loader, numberOfItems: { () -> Int in
//            return urls.count
//        }, placeholder: { (inx) -> UIImage? in
//            return nil
//        }, autoloadURLString: { (inx) -> String? in
//            return urls[inx]
//        }) { (inx) -> String? in
//            return urls[inx]
//        }
//        
//        JXPhotoBrowser(dataSource: src).show(pageIndex: button.tag)
        let vc = GalleryViewController(startIndex: button.tag, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
}

/// 链接点击 目前只支持 用户名点击
extension StatusRepostView_ASDK: ASTextNodeDelegate {
    
    func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
        
        let str = (self.model!.textString as NSString).substring(with: textRange)
        MTLog(msg: str)
        self.delegate?.statusRepUserNameClick(name: str)
        
    }
    
}


/// 图片浏览框架代理
extension StatusRepostView_ASDK: GalleryItemsDataSource {
    func itemCount() -> Int {
        
        return self.model!.pic_urls!.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        
        var items = [GalleryItem]()
        for url in self.model!.pic_urls! {
            
            let imageURL = URL(string: url.middlePic!)!
            let galleryItem = GalleryItem.image { imageCompletion in
                imageURL.downloadImage(completion: imageCompletion)
            }
            items.append(galleryItem)
        }
        
        return items[index]
    }
    
    
    
    func galleryConfiguration() -> GalleryConfiguration {
        
        return [
            
            GalleryConfigurationItem.closeButtonMode(.none),
            
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(true),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(true),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffect.Style.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
}
