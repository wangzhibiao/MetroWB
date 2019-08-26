//
//  StatusCell_ASDK.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/31.
//
import UIKit
import SnapKit
import Kingfisher
import YYText

import AVFoundation
import AsyncDisplayKit
import Material
//import Nuke
//import Lightbox
//import AXPhotoViewer
import MobilePlayer
//import Agrume
import JXPhotoBrowser


// 播放按钮闭包
protocol StatusCell_ASDKDelegate {
    func statusTextClick(indexpath: IndexPath)
    func statusUserNameClick(name: String)
    
}

/// 微博cell视图
class StatusCell_ASDK: ASCellNode {
    
    // 头像
    let avatarImageView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 昵称
    let screenNameLable = ASTextNode()
    // 是否加V用户
    let verifiedImageView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 转发数
    let repostButton = ASButtonNode()
    // 评论数
    let commentsButton = ASButtonNode()
    // 来源
    let sourceLable = ASTextNode()
    // 日期
    let dateTimeLable = ASTextNode()
    // 微博内容
    let conentTextView = ASTextNode()
    // 转发微博背景view
    var repostBGView = ASDisplayNode()
    // 更换texture布局后 九宫格目前先要定义九个图片 用到几个布局几个
    lazy var imgNodeArray = [ASDisplayNode]()
    // 视频view
    let videoContentView: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        return node
    }()
    // 播放按钮
    let palyBtn = ASImageNode()

    // 分割Ian
    let lineView = ASDisplayNode()
    // 背景图
    let bgShowView = ASDisplayNode()
    
    // 是否显示全文属性 在详情界面 是要讲内容全部显示出来的
    var isShowAll:Bool = false
    // 视频模型
    var videoModel:ObjectModel?
    
    // block
    var delegate:StatusCell_ASDKDelegate?
    var _indexPath:IndexPath?
    // 懒加载破放弃
    lazy var player = ASVideoNode()
    // 微博模型
    var model:StatusModel?
   
    
    
    func setIndexPathAndDelegate(inx: IndexPath, withDelegate: StatusCell_ASDKDelegate){
        self._indexPath = inx
        self.delegate = withDelegate
    }
    
    init(model: StatusModel, inx: IndexPath) {
        super.init()
        self.model = model
        self._indexPath = inx
        // 背景色
        self.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        
        // 自动管理node
        automaticallyManagesSubnodes = true
        self.bgShowView.backgroundColor = ConstFile.gloab_bg_color//Color.grey.darken3//
        DispatchQueue.main.async {
//            self.bgShowView.layer.shadowRadius = 3
//            self.bgShowView.layer.shadowColor = UIColor.gray.cgColor
//            self.bgShowView.layer.shadowOpacity = 0.5
//            self.bgShowView.layer.shadowOffset = CGSize(width: 1, height: 0)
        
        }
        
        if model.user != nil {
            // 头像
            self.avatarImageView.url = URL(string: model.user!.avatar_large!)
            // 名字
            let nameAttr = model.user!.screen_name!.attributesStringWith(font: UIFont.systemFont(ofSize: 18, weight: .bold), color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
            self.screenNameLable.attributedText = nameAttr
        }
        
        // 评论数
        self.commentsButton.setImage(UIImage(named: "timeline_icon_comment"), for: .normal)
        self.commentsButton.setTitle(model.comments_count.description.formatDesc, with: UIFont.systemFont(ofSize: 14), with: ConstFile.status_small_text_color, for: .normal)
        // 转发数
        self.repostButton.setImage(UIImage(named: "timeline_icon_retweet"), for: .normal)
        self.repostButton.setTitle(model.reposts_count.description.formatDesc, with: UIFont.systemFont(ofSize: 14), with: ConstFile.status_small_text_color, for: .normal)
        
        // 正文
        // 转成 NSMutableAttributedString
        var attributeString = model.textString.attributesStringWith(font: ConstFile.status_text_font, color: ConstFile.gloab_font_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        
        // 替换链接 视频或网页链接
        let tuple = RichTxtTool.setupAttributestring(m: model, attributeString: attributeString)
        let txt = tuple.0
        self.videoModel = tuple.2
        attributeString = tuple.1
        
        // 替换表情
        let attribute = EmoticonTools.shared.emoctionString(str: attributeString.string, font: ConstFile.status_text_font)
        attributeString = NSMutableAttributedString(attributedString: attribute)
        // 增加高亮显示
        RichTxtTool.addHighlightedAll(strM: &attributeString, isAll: false, font: ConstFile.status_text_font, specTxt: txt)
        
        self.conentTextView.attributedText = attributeString
        self.conentTextView.isUserInteractionEnabled = true
        self.conentTextView.delegate = self
        self.conentTextView.addTarget(self, action: #selector(txtClick(txt:)), forControlEvents: .touchUpInside)
        
        
        
        if model.retweeted_status != nil {
            self.repostBGView = StatusRepostView_ASDK(model: model.retweeted_status!, idp: self._indexPath!)
            (self.repostBGView as! StatusRepostView_ASDK).delegate = self
            
        }
        
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
            // 根据用户设置的是否仅在wifi下自动播放视频来设置
            self.player.shouldAutoplay = false
            let autoplay = UserDefaults.standard.value(forKey: ConstFile.auto_play_userdefault) as! Bool
            if autoplay && MTNetWorkTools.shared.statusStr == .wifi {
                self.player.shouldAutoplay = true
            }
        
            self.player.muted = true
            
            self.player.url = URL(string: self.videoModel!.image!.url)
            
            var videoUrl = ""
            if self.videoModel?.stream != nil &&
                self.videoModel?.stream.url != nil {
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
        
        // 日期
        let dateAttr = model.createAtTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.dateTimeLable.attributedText = dateAttr
        
        // 来源
        let srcAttr = model.sourceTxt.attributesStringWith(font: UIFont.systemFont(ofSize: 14), color: ConstFile.status_small_text_color, kern: ConstFile.status_text_kern as NSNumber, lineSpace: ConstFile.text_marging)
        self.sourceLable.attributedText = srcAttr
        
        // 分割线
        self.lineView.backgroundColor = ConstFile.gloab_repost_bg_color
        
    }
    
    @objc func txtClick(txt: ASTextNode){
        
        self.delegate?.statusTextClick(indexpath: self.indexPath!)
    }
    
    
    /// 布局组件
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // 所有布局数组
        var specArray = [ASLayoutSpec]()
        
        self.avatarImageView.style.preferredSize = CGSize(width: 35, height: 35)
//        self.avatarImageView.cornerRadius = 22
        // 左侧头像和姓名
        let leftImgNameSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .start, children: [self.avatarImageView, self.screenNameLable])
        // 右侧 评论和转发
        let rightSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: ASStackLayoutJustifyContent.center, alignItems: .end, children: [self.commentsButton,self.repostButton])
        // 顶部stackview
        let topSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .spaceBetween, alignItems: .center, children: [leftImgNameSpec, rightSpec])
        let topinset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0), child: topSpec)
        specArray.append(topinset)
        
        // 详情布局
        let textSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0), child: self.conentTextView)
//        specArray.append(textSpec)
        
        // 布局图片 注意图片和视频同时存在的情况 只显示图片 有转发的微博 就不显示i自身的图片或视频
        if self.model?.retweeted_status != nil {
            // 转发微博布局
            let repostSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0), child: self.repostBGView)
            
            let textRepostSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, repostSpec])
            specArray.append(textRepostSpec)
        }
        else if self.imgNodeArray.count > 0 {// 自身图片布局
            
            let oneW: CGFloat = ConstFile.ScreenW-40
            let twoW: CGFloat = (ConstFile.ScreenW)/3
            let threeW: CGFloat = (ConstFile.ScreenW-50)/3
            
            // 最多9张图 每种情况都做好布局
            switch self.imgNodeArray.count {
            case 1:
                
                let node = self.imgNodeArray.first!
                node.style.preferredSize = CGSize(width: oneW, height: 220)
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [node])
//                specArray.append(nodeSpec)
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
           
            case 2:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: twoW, height: twoW)
                    nodes.append(node)
                }
                
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: nodes)
//                specArray.append(nodeSpec)
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
            case 3:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let nodeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .stretch, children: nodes)
//                specArray.append(nodeSpec)
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
            
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
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
           
            case 5:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[3], nodes[4]])
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec])
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
            
            case 6:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec])
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
           
            case 7:
                
                var nodes = [ASDisplayNode]()
                for img in self.imgNodeArray {
                    
                    let node = img
                    node.style.preferredSize = CGSize(width: threeW, height: threeW)
                    nodes.append(node)
                }
                
                let oneSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[0], nodes[1], nodes[2]])
                let twoSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[3], nodes[4], nodes[5]])
                
                let threeSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [nodes[6]])
                
                let nodeSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [oneSpec, twoSpec, threeSpec])
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
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
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
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
                
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, nodeSpec])
                specArray.append(textphotoSpec)
                
            default:
                break
            }
            
        }else if self.model!.isContentVideo && self.videoModel != nil {
            
            let videoW: CGFloat = ConstFile.ScreenW-50
            if self.model!.isVeritical {
//
                let w: CGFloat = videoW*3/4
                self.player.style.preferredSize = CGSize(width: w, height: videoW)
                let spec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .center, children: [self.player])
                
                // 播放按钮
                self.palyBtn.style.preferredSize = CGSize(width: 50, height: 50)
                let playSpec = ASCenterLayoutSpec(horizontalPosition: .center, verticalPosition: .center, sizingOption: .init(rawValue: 0), child: self.palyBtn)
                    //ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: (w-50)/2, bottom: 0, right: 0), child: self.palyBtn)
                    //ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .init(rawValue: 0), child: self.palyBtn)
                let overSpec = ASOverlayLayoutSpec(child: spec, overlay: playSpec)
                

                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, overSpec])
                specArray.append(textphotoSpec)
                
            }else {
                self.player.style.preferredSize = CGSize(width: videoW, height: videoW*9/16)
                let spec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .center, alignItems: .start, children: [self.player])
//                specArray.append(spec)
                // 播放按钮
                self.palyBtn.style.preferredSize = CGSize(width: 50, height: 50)
                let playSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .init(rawValue: 0), child: self.palyBtn)
                let overSpec = ASOverlayLayoutSpec(child: spec, overlay: playSpec)
//                specArray.append(overSpec)
                let textphotoSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [textSpec, overSpec])
                specArray.append(textphotoSpec)
            }
            
        }else { // 注意 如果没图 没视频 没转发 那么久只加入文字布局
            specArray.append(textSpec)
        }
        
        // 日期和来源
        let dateSrcSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [self.dateTimeLable, self.sourceLable])
        // 分割线
        self.lineView.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        let lineSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.lineView)
        
        let dateLineSpec = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [dateSrcSpec, lineSpec])
        
        specArray.append(dateLineSpec)
        
//         self.bgShowView.style.preferredSize = CGSize(width: ConstFile.ScreenW-40, height: 1)
        
        // 所有空间垂直排列
        let allSpec = ASStackLayoutSpec(direction: .vertical, spacing: 20, justifyContent: .start, alignItems: .stretch, children: specArray)
        let resultSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 20, bottom: 10, right: 20), child: allSpec)
        
       
        let bgs = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: self.bgShowView)
        let bgspec = ASBackgroundLayoutSpec(child: resultSpec, background: bgs)
        
        return bgspec
    }
    
}

//  视频代理控制播放器各个功能
extension StatusCell_ASDK: ASVideoNodeDelegate {
    
   
    func didTap(_ videoNode: ASVideoNode) {
        if videoNode.isPlaying() {
            videoNode.pause()
            
            let url = URL(string: self.videoModel!.stream.hd_url!)
           
            DispatchQueue.main.async {
                 let popVC = MobilePlayerViewController(contentURL: url!)
                popVC.title = self.videoModel!.titles[0].title
                popVC.fitVideo()
                
                UIApplication.shared.keyWindow!.rootViewController!.present(popVC, animated: true, completion: nil)
            }
            
//               var galleryItem = GalleryItem.video(fetchPreviewImageBlock: { imageCompletion in
//                url!.downloadImage(completion: imageCompletion)
//               }, videoURL: url!)
            
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
    
    
    // 移除视频播放器 并暂停
    func removVideoView(){
        if player.isPlaying() {
            player.pause()
        }
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
        
        let vc = GalleryViewController(startIndex: button.tag, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
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


/// 图片浏览框架代理
extension StatusCell_ASDK: GalleryItemsDataSource {
    func itemCount() -> Int {
        
        return self.model!.pic_urls!.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        
        var items = [GalleryItem]()
        for url in self.model!.pic_urls! {
            MTLog(msg: url.middlePic!)
            let imageURL = URL(string: url.middlePic!)!
            let galleryItem = GalleryItem.image { imageCompletion in
                imageURL.downloadImage(completion: imageCompletion)
            }
            items.append(galleryItem)
        }
        
        return items[index]
    }
    
}

/// 链接点击 目前只支持 用户名点击
extension StatusCell_ASDK: ASTextNodeDelegate,StatusRepostView_ASDKDelegate {
    
    func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
        
        let name = value as! String
        
        self.delegate?.statusUserNameClick(name: name)
        
    }
    
    func statusRepUserNameClick(name: String) {
        self.delegate?.statusUserNameClick(name: name)
    }
    
    func statusRepTextClick(indexpath: IndexPath) {
        self.delegate?.statusTextClick(indexpath: indexpath)
    }
    
}
