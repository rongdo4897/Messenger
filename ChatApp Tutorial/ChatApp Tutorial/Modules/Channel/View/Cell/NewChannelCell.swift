//
//  NewChannelCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import UIKit

protocol NewChannelCellDelegate: AnyObject {
    func tapAvatar()
    func changeChannelName(text: String)
    func changeAboutChannel(text: String)
}

class NewChannelCell: BaseTBCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblAboutChannel: UILabel!
    @IBOutlet weak var tfChannelName: UITextField!
    @IBOutlet weak var txtChannelInfo: UITextView!
    
    weak var delegate: NewChannelCellDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initComponents()
        customizeComponents()
        selectionStyle = .none
    }
    
    @IBAction func tfChannelNameEdittingChange(_ sender: Any) {
        delegate?.changeChannelName(text: tfChannelName.text ?? "")
    }
}

//MARK: - Action - Obj
extension NewChannelCell {
    @objc func tapAvatar() {
        delegate?.tapAvatar()
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension NewChannelCell {
    private func initComponents() {
        initLocalizable()
        initTextView()
        initImage()
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
    
    private func initImage() {
        imgAvatar.image = UIImage(named: "ic_avatar")
        imgAvatar.isUserInteractionEnabled = true
        imgAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAvatar)))
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
    func setUpData(channel: Channel) {
        tfChannelName.text = channel.name
        
        setTextViewAboutChannel(text: channel.aboutChannel)
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func setTextViewAboutChannel(text: String) {
        if text != "" {
            txtChannelInfo.text = text
            txtChannelInfo.textColor = .black
        } else {
            txtChannelInfo.text = "Channel info".localized()
            txtChannelInfo.textColor = .lightGray
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
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.changeAboutChannel(text: textView.text)
    }
}
