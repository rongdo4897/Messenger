//
//  ChatCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 11/06/2021.
//

import UIKit

class ChatCell: BaseTBCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblUnReadCounter: UILabel!
    @IBOutlet weak var viewUnReadCounter: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action, Obj
extension ChatCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChatCell {
    private func initComponents() {
        initLabels()
    }
    
    private func initLabels() {
        lblName.adjustsFontSizeToFitWidth = true
        lblName.minimumScaleFactor = 0.9
        
        lblMessage.adjustsFontSizeToFitWidth = true
        lblMessage.minimumScaleFactor = 0.9
        lblMessage.numberOfLines = 2
        
        lblDate.adjustsFontSizeToFitWidth = true
        lblDate.minimumScaleFactor = 0.9
    }
}

//MARK: - Customize
extension ChatCell {
    private func customizeComponents() {
        customizeImage()
        customizeView()
    }
    
    
    private func customizeImage() {
        DispatchQueue.main.async {
            self.imgAvatar.layer.cornerRadius = self.imgAvatar.height / 2
        }
    }
    
    private func customizeView() {
        viewUnReadCounter.layer.cornerRadius = viewUnReadCounter.height / 2
    }
}

//MARK: - Các hàm chức năng
extension ChatCell {
    func setUpData(recent: RecentChat?) {
        // Tên
        lblName.text = recent?.receiverName ?? ""
        // Tin nhắn cuối
        lblMessage.text = recent?.lastMessage.localized() ?? ""
        
        // Số lượng tin nhắn
        if recent?.unreadCounter != 0 {
            self.lblUnReadCounter.text = "\(recent?.unreadCounter ?? 0)"
            self.viewUnReadCounter.isHidden = false
        } else {
            self.viewUnReadCounter.isHidden = true
        }
        
        // ảnh
        if recent?.avatarLink != "" {
            FireStorage.share.downloadImage(imageUrl: recent?.avatarLink ?? "") { image in
                self.imgAvatar.image = image?.circleMasked
                self.imgAvatar.contentMode = .scaleAspectFit
            }
        } else {
            imgAvatar.image = UIImage(named: "ic_avatar")
            imgAvatar.contentMode = .scaleToFill
        }
        
        // Ngày
        lblDate.text = timeElapsed(recent?.date ?? Date())
    }
}
