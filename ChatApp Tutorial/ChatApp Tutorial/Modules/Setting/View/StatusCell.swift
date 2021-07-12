//
//  StatusCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import UIKit

class StatusCell: BaseTBCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension StatusCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension StatusCell {
    private func initComponents() {
        
    }
}

//MARK: - Customize
extension StatusCell {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension StatusCell {
    func setUpData(text: String) {
        lblName.text = text.localized()
    }
}
