//
//  UserDetailCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 16/06/2021.
//

import UIKit

protocol UserDetailCellDelegate: AnyObject {
    func tapViewChat(user: User)
}

class UserDetailCell: BaseTBCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStartChat: UILabel!
    @IBOutlet weak var viewChat: UIView!
    
    weak var delegate: UserDetailCellDelegate?
    
    var user = User()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension UserDetailCell {
    @objc func tapChatView() {
        delegate?.tapViewChat(user: self.user)
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension UserDetailCell {
    private func initComponents() {
        initLocalizableText()
        initView()
    }
    
    private func initLocalizableText() {
        lblStartChat.text = "Start Chat".localized()
    }
    
    private func initView() {
        viewChat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapChatView)))
    }
}

//MARK: - Customize
extension UserDetailCell {
    private func customizeComponents() {
        customizeImage()
    }
    
    private func customizeImage() {
        DispatchQueue.main.async {
            self.imgUser.layer.cornerRadius = self.imgUser.height / 2
        }
    }
}

//MARK: - Các hàm chức năng
extension UserDetailCell {
    func setUpData(user: User?) {
        self.user = user!
        
        lblName.text = user?.userName ?? ""
        lblStatus.text = (user?.status ?? "").localized()
        
        if user?.avatarLink != "" {
            FireStorage.share.downloadImage(imageUrl: user?.avatarLink ?? "") { image in
                self.imgUser.image = image?.circleMasked
                self.imgUser.contentMode = .scaleAspectFit
            }
        } else {
            imgUser.image = UIImage(named: "ic_avatar")
            imgUser.contentMode = .scaleToFill
        }
    }
}
