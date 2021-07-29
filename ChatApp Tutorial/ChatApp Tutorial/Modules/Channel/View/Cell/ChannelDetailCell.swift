//
//  ChannelDetailCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 29/07/2021.
//

import UIKit

class ChannelDetailCell: BaseTBCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    @IBOutlet weak var txtAbout: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension ChannelDetailCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChannelDetailCell {
    private func initComponents() {
        initTextView()
    }
    
    private func initTextView() {
        txtAbout.text = "Channel info".localized()
        txtAbout.textColor = .lightGray
        txtAbout.isUserInteractionEnabled = false
    }
}

//MARK: - Customize
extension ChannelDetailCell {
    private func customizeComponents() {
        customizeImage()
    }
    
    private func customizeImage() {
        DispatchQueue.main.async {
            self.imgAvatar.layer.cornerRadius = self.imgAvatar.height / 2
        }
    }
}

//MARK: - Các hàm chức năng
extension ChannelDetailCell {
    func setUpData(channel: Channel) {
        lblName.text = channel.name
        lblMember.text = String(channel.memberIds.count) + " " + "members".localized()
        
        setTextViewAboutChannel(text: channel.aboutChannel)
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func setTextViewAboutChannel(text: String) {
        if text != "" {
            txtAbout.text = text
            txtAbout.textColor = .black
        } else {
            txtAbout.text = "Channel info".localized()
            txtAbout.textColor = .lightGray
        }
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FireStorage.share.downloadImage(imageUrl: avatarLink) { image in
                DispatchQueue.main.async {
                    if image != nil {
                        self.imgAvatar.image = image?.circleMasked
                    } else {
                        self.imgAvatar.image = UIImage(named: "ic_avatar")
                    }
                }
            }
        } else {
            self.imgAvatar.image = UIImage(named: "ic_avatar")
        }
    }
}
