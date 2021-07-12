//
//  ProfileCell.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func tapViewStatus()
    func tapEditButton()
}

class ProfileCell: BaseTBCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewAtTheMovies: UIView!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    weak var delegate: ProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnEditTapped(_ sender: Any) {
        delegate?.tapEditButton()
    }
}

//MARK: - Action - Obj
extension ProfileCell {
    @objc func tapAtTheMovieView() {
        delegate?.tapViewStatus()
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension ProfileCell {
    private func initComponents() {
        initLocalizableText()
        initViews()
        initTextFields()
    }
    
    private func initLocalizableText() {
        lblText.text = "Enter your name and add an optional profile picture".localized()
        lblStatus.text = "Select status".localized()
        btnEdit.setTitle("Edit".localized(), for: .normal)
        tfUserName.placeholder = "Username".localized()
    }
    
    private func initViews() {
        viewAtTheMovies.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAtTheMovieView)))
    }
    
    private func initTextFields() {
        tfUserName.delegate = self
        tfUserName.clearButtonMode = .whileEditing
    }
}

//MARK: - Customize
extension ProfileCell {
    private func customizeComponents() {
        customImage()
    }
    
    private func customImage() {
        DispatchQueue.main.async {
            self.imgUser.layer.cornerRadius = self.imgUser.height / 2
        }
    }
}

//MARK: - Các hàm chức năng
extension ProfileCell {
    func showUserInfo(_ user: User?) {
        lblStatus.text = (user?.status ?? "").localized()
        tfUserName.text = user?.userName ?? ""
        
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

//MARK: - Textfield delegate
extension ProfileCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfUserName:
            if textField.text != "" {
                if var user = LocalResourceRepository.getUserLocally() {
                    user.userName = textField.text!
                    // Lưu user mới vào local
                    LocalResourceRepository.setUserLocally(user: user)
                    // Lưu user mới vào firebase firestore
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            } else {
                textField.text = LocalResourceRepository.getUserLocally()?.userName ?? ""
            }
            
            textField.resignFirstResponder()
            return false
        default:
            return true
        }
    }
}
