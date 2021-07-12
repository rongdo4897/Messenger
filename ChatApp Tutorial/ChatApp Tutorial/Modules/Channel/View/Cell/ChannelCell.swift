//
//  ChannelCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import UIKit

class ChannelCell: BaseTBCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
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
            self.imgUser.layer.cornerRadius = self.imgUser.height / 2
        }
    }
}

//MARK: - Các hàm chức năng
extension ChannelCell {
    
}
