//
//  SettingCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 11/06/2021.
//

import UIKit

protocol SettingCellDelegate: AnyObject {
    func clickViewUser()
    func clickViewTell()
    func clickViewTerms()
    func clickViewLogout()
}

class SettingCell: BaseTBCell {
    @IBOutlet weak var lblTell: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var viewTell: UIView!
    @IBOutlet weak var viewTerms: UIView!
    @IBOutlet weak var viewLogout: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    weak var delegate: SettingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
}

//MARK: - Action - Obj
extension SettingCell {
    @objc func tapUserView() {
        delegate?.clickViewUser()
    }
    
    @objc func tapTellView() {
        delegate?.clickViewTell()
    }
    
    @objc func taptermsView() {
        delegate?.clickViewTerms()
    }
    
    @objc func tapLogoutView() {
        delegate?.clickViewLogout()
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension SettingCell {
    private func initComponents() {
        initDefaultLocalizableText()
        initActionView()
    }
    
    private func initDefaultLocalizableText() {
        lblTell.text = "Tell A Friend".localized()
        lblTerms.text = "Terms and Conditions".localized()
        lblLogout.text = "Log Out".localized()
    }
    
    private func initActionView() {
        viewUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUserView)))
        viewTell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTellView)))
        viewTerms.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(taptermsView)))
        viewLogout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLogoutView)))
    }
}

//MARK: - Customize
extension SettingCell {
    private func customizeComponents() {
        customizeImage()
    }
    
    private func customizeImage() {
        imgUser.layer.cornerRadius = imgUser.height / 2
    }
}

//MARK: - Các hàm chức năng
extension SettingCell {
    func showUserInfo(_ user: User?) {
        lblName.text = user?.userName ?? ""
        lblStatus.text = (user?.status ?? "").localized()
        
        if user?.avatarLink != "" {
            FireStorage.share.downloadImage(imageUrl: user?.avatarLink ?? "") { image in
                self.imgUser.image = image?.circleMasked
                self.imgUser.contentMode = .scaleAspectFit
            }
        } else {
            imgUser.contentMode = .scaleToFill
            imgUser.image = UIImage(named: "ic_avatar")
        }
        
        // version
        lblVersion.text = "Version".localized() + " \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
}
