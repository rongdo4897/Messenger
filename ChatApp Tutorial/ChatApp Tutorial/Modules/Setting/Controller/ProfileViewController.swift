//
//  ProfileViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import UIKit
import Gallery
import ProgressHUD

protocol ProfileViewControllerDelegate: AnyObject {
    func reloadData()
}

//MARK: - Outlet, Override
class ProfileViewController: UIViewController {
    @IBOutlet weak var tblProfile: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    weak var delegate: ProfileViewControllerDelegate?
    
    var gallery: GalleryController!
    var cellProfile: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        delegate?.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action - Obj
extension ProfileViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ProfileViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Profile".localized()
    }
    
    private func initTableView() {
        ProfileCell.registerCellByNib(tblProfile)
        tblProfile.dataSource = self
        tblProfile.delegate = self
        tblProfile.separatorStyle = .none
        tblProfile.showsVerticalScrollIndicator = false
        tblProfile.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblProfile.width, height: 0))
    }
}

//MARK: - Customize
extension ProfileViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension ProfileViewController {
    func uploadAvatarImage(_ image: UIImage) {
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FireStorage.share.uploadImage(image, directory: fileDirectory) { avatarLink in
            if var user = LocalResourceRepository.getUserLocally() {
                user.avatarLink = avatarLink ?? ""
                // Lưu vào local
                LocalResourceRepository.setUserLocally(user: user)
                // Lưu vào firestore
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            
            // Lưu image vào local
            FireStorage.share.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }
}

//MARK: - TableView
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ProfileCell.loadCell(tableView) as? ProfileCell else {return UITableViewCell()}
        cell.delegate = self
        cell.showUserInfo(LocalResourceRepository.getUserLocally())
        self.cellProfile = cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - ProfileCellDelegate
extension ProfileViewController: ProfileCellDelegate {
    func tapViewStatus() {
        guard let vc = RouterType.status.getVc() as? StatusViewController else {return}
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tapEditButton() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        // Cấu hình tab
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
}

//MARK: - Gallery delegate
extension ProfileViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { imgAvatar in
                if imgAvatar != nil {
                    // upload leen storage
                    self.uploadAvatarImage(imgAvatar!)
                    // hiển thị lên cell
                    guard let cell = self.cellProfile as? ProfileCell else {return}
                    cell.imgUser.image = imgAvatar?.circleMasked
                } else {
                    ProgressHUD.showError("Don't select image".localized())
                }
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - StatusViewControllerDelegate
extension ProfileViewController: StatusViewControllerDelegate {
    func reloadData() {
        tblProfile.reloadData()
    }
}
