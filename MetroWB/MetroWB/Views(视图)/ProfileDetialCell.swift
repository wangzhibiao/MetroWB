//
//  ProfileDetialCell.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/7/1.
//

import UIKit
import SnapKit


enum ProfileButtonType: Int {
    case STATUS
    case FANS
    case FOLLOW
}

// 粉丝 微博 关注按钮点击代理方法
protocol ProfileDetialCellDelegate {
    func buttonClick(type: ProfileButtonType)
}


/// 个人资料cell
class ProfileDetialCell: UITableViewCell {

    // 头像
    var avatarImageView:UIImageView!
    // 姓名
    var screenNameLable:UILabel!
    // 性别
    var sexLable:UILabel!
    // 区域
    var eareLable:UILabel!
    // 加关注按钮 当不是当前登录用户的主页时候要显示 加关注|已关注 按钮
    var isFollowButton:UIButton!
    // 简介
    var detialCommentLable:UILabel!
    // 微博
    var statusButton:UIButton!
    // 关注
    var followButton:UIButton!
    // 粉丝
    var fansButton:UIButton!
    // 代理
    var delegate:ProfileDetialCellDelegate?
    
    
    // 用户模型
    var model:UserModel? {
        didSet{
            guard let user = model else {
                return
            }
            
            // 给属性设置值
            let url = URL(string: user.avatar_large!)
            self.avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_img"))
            
            self.screenNameLable.text = user.screen_name
            self.sexLable.text = user.genderStr
            self.eareLable.text = user.location ?? "未设置区域"
            let desc = user.desc == nil ? "这家伙很懒~啥也没留下" : user.desc!
            self.detialCommentLable.text = "简介: " + desc
            
            self.statusButton.setTitle("微博 \(user.statuses_count.description)", for: .normal)
            self.fansButton.setTitle("粉丝 \(user.friends_count.description)", for: .normal)
            self.followButton.setTitle("关注 \(user.followers_count.description)", for: .normal)
            
            if user.id == MTNetWorkTools.shared.userAccess.id {
                self.isFollowButton.isHidden = true
            }else {
                self.isFollowButton.isHidden = false
                let str = user.following == true ? "已关注" : "加关注"
                self.isFollowButton.setTitle(str, for: .normal)
            }
            
        }
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ProfileDetialCell {
    
    func setupUI(){
        
        // 背景色
        self.contentView.backgroundColor = ConstFile.gloab_bg_color
        self.selectionStyle = .none
        // 用户头像
        self.avatarImageView = UIImageView()
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.clipsToBounds = true
        self.contentView.addSubview(self.avatarImageView)
        
        self.avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(120)
        }
        
        // 用户昵称
        self.screenNameLable = UILabel()
        self.screenNameLable.textColor = ConstFile.gloab_font_color
        self.screenNameLable.font = UIFont.systemFont(ofSize: 18, weight: .light)
        self.contentView.addSubview(self.screenNameLable)
        
        self.screenNameLable.snp.makeConstraints { (make) in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.left.equalTo(self.avatarImageView.snp.right).offset(10)
        }
        
        // 用户性别
        self.sexLable = UILabel()
        self.sexLable.textColor = ConstFile.gloab_sub_font_color
        self.sexLable.font = UIFont.systemFont(ofSize: 16, weight: .light)
        self.contentView.addSubview(self.sexLable)
        
        self.sexLable.snp.makeConstraints { (make) in
            make.top.equalTo(self.screenNameLable.snp.bottom).offset(20)
            make.left.equalTo(self.avatarImageView.snp.right).offset(10)
        }
        
        // 用户区域
        self.eareLable = UILabel()
        self.eareLable.textColor = ConstFile.gloab_sub_font_color
        self.eareLable.font = UIFont.systemFont(ofSize: 15, weight: .light)
        self.contentView.addSubview(self.eareLable)
        
        self.eareLable.snp.makeConstraints { (make) in
            make.top.equalTo(self.screenNameLable.snp.bottom).offset(20)
            make.left.equalTo(self.sexLable.snp.right).offset(10)
        }
        
        // 加关注按钮
        self.isFollowButton = UIButton()
        self.isFollowButton.layer.borderColor = ConstFile.gloab_font_color.cgColor
        self.isFollowButton.layer.borderWidth = 1
        self.isFollowButton.setTitleColor(ConstFile.gloab_font_color, for: .normal)
//        self.sexLable.textColor = ConstFile.gloab_font_color
//        self.sexLable.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.contentView.addSubview(self.isFollowButton)
        
        self.isFollowButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.sexLable.snp.bottom).offset(10)
            make.left.equalTo(self.avatarImageView.snp.right).offset(10)
        }
        
        // 简介
        self.detialCommentLable = UILabel()
        self.detialCommentLable.textColor = ConstFile.gloab_sub_font_color
        self.detialCommentLable.font = UIFont.systemFont(ofSize: 17, weight: .light)
        self.contentView.addSubview(self.detialCommentLable)
        
        self.detialCommentLable.snp.makeConstraints { (make) in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(20)
            make.leading.equalTo(self.avatarImageView)
        }
        
        // 关注 微博 粉丝
        let btnw:CGFloat = (ConstFile.ScreenW - 40) / 3
        self.followButton = UIButton()
        self.followButton.tag = ProfileButtonType.FOLLOW.rawValue
        self.followButton.setTitleColor(ConstFile.status_high_color, for: .normal)
        //        self.sexLable.textColor = ConstFile.gloab_font_color
        //        self.sexLable.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.contentView.addSubview(self.followButton)
        self.followButton.addTarget(self, action: #selector(buttonClick(sendr:)), for: .touchUpInside)
        self.followButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.detialCommentLable.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(btnw)
        }
        
        self.statusButton = UIButton()
        self.statusButton.tag = ProfileButtonType.STATUS.rawValue
        self.statusButton.setTitleColor(ConstFile.status_high_color, for: .normal)
        //        self.sexLable.textColor = ConstFile.gloab_font_color
        //        self.sexLable.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.contentView.addSubview(self.statusButton)
        self.statusButton.addTarget(self, action: #selector(buttonClick(sendr:)), for: .touchUpInside)
        self.statusButton.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.followButton)
            make.width.equalTo(btnw)
            make.left.equalToSuperview().offset(10)
            
        }
        
        
        self.fansButton = UIButton()
        self.fansButton.setTitleColor(ConstFile.status_high_color, for: .normal)
        //        self.sexLable.textColor = ConstFile.gloab_font_color
        //        self.sexLable.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.fansButton.tag = ProfileButtonType.FANS.rawValue
        self.fansButton.addTarget(self, action: #selector(buttonClick(sendr:)), for: .touchUpInside)
        self.contentView.addSubview(self.fansButton)
        
        self.fansButton.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
            make.width.equalTo(btnw)
            make.centerY.equalTo(self.followButton)
            make.right.equalToSuperview().offset(-10)
        }
        
    }
    
    
    // 代理方法
    @objc func buttonClick(sendr: UIButton){
        self.delegate?.buttonClick(type: ProfileButtonType(rawValue: sendr.tag)!)
    }
    
}
