//
//  ChannelCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import UIKit

class ChannelCell: BaseTBCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblMemberCount: UILabel!
    @IBOutlet weak var lblLastMessageDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension ChannelCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChannelCell {
    private func initComponents() {
        
    }
}

//MARK: - Customize
extension ChannelCell {
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
extension ChannelCell {
    func setUpData(channel: Channel) {
        lblName.text = channel.name
        lblAbout.text = channel.aboutChannel
        lblMemberCount.text = String(channel.memberIds.count) + " " + "members".localized()
        lblLastMessageDate.text = timeElapsed(channel.lastMessageDate ?? Date())
        lblLastMessageDate.adjustsFontSizeToFitWidth = true
        
        // ảnh
        if channel.avatarLink != "" {
            FireStorage.share.downloadImage(imageUrl: channel.avatarLink) { image in
                if image != nil {
                    self.imgAvatar.image = image!.circleMasked
                    self.imgAvatar.contentMode = .scaleAspectFit
                } else {
                    self.imgAvatar.image = UIImage(named: "ic_avatar")
                    self.imgAvatar.contentMode = .scaleToFill
                }
            }
        } else {
            imgAvatar.image = UIImage(named: "ic_avatar")
            imgAvatar.contentMode = .scaleToFill
        }
    }
}
