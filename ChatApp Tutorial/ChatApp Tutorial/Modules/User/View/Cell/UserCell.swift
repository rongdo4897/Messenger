//
//  UserCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import UIKit

class UserCell: BaseTBCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension UserCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension UserCell {
    private func initComponents() {
        
    }
}

//MARK: - Customize
extension UserCell {
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
extension UserCell {
    func setUpData(user: User?) {
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
