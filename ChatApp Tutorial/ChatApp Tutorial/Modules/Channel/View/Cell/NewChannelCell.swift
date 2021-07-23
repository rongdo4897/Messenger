//
//  NewChannelCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import UIKit

class NewChannelCell: BaseTBCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblAboutChannel: UILabel!
    @IBOutlet weak var tfChannelName: UITextField!
    @IBOutlet weak var txtChannelInfo: UITextView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initComponents()
        customizeComponents()
        selectionStyle = .none
    }
}

//MARK: - Action - Obj
extension NewChannelCell {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension NewChannelCell {
    private func initComponents() {
        initLocalizable()
        initTextView()
    }
    
    private func initLocalizable() {
        lblAboutChannel.text = "About Channel".localized()
        tfChannelName.placeholder = "Channel Name".localized()
    }
    
    private func initTextView() {
        txtChannelInfo.text = "Channel info".localized()
        txtChannelInfo.textColor = .lightGray
        txtChannelInfo.delegate = self
    }
}

//MARK: - Customize
extension NewChannelCell {
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
extension NewChannelCell {
    func setUpData() {
        
    }
}

//MARK: - UITextViewDelegate
extension NewChannelCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Channel info".localized()
            textView.textColor = .lightGray
        } else {
            textView.textColor = .black
        }
    }
}
