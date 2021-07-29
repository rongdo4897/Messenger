//
//  NewChannelViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import UIKit
import Gallery
import ProgressHUD

//MARK: - Outlet, Override
class NewChannelViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblChannel: UITableView!
    
    var gallery: GalleryController!
    var cellNewChannel = UITableViewCell()
    
    var avatarLink = ""
    var channelId = UUID().uuidString
    
    var nameChannel = ""
    var aboutChannel = ""
    
    var channelToEdit: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveTapped(_ sender: Any) {
        if nameChannel != "" {
            if channelToEdit != nil {
                editChannel()
            } else {
                addChannel()
            }
        } else {
            ProgressHUD.showError("Channel name isn't empty!".localized())
        }
    }
}

//MARK: - Action - Obj
extension NewChannelViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension NewChannelViewController {
    private func initComponents() {
        initTableView()
        initTitle()
        initChannelType()
    }
    
    private func initTableView() {
        NewChannelCell.registerCellByNib(tblChannel)
        tblChannel.dataSource = self
        tblChannel.delegate = self
        tblChannel.separatorInset.left = 0
        tblChannel.showsVerticalScrollIndicator = true
        tblChannel.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChannel.width, height: 0))
    }
    
    private func initTitle() {
        if channelToEdit != nil {
            lblTitle.text = "Edit Channel".localized()
        } else {
            lblTitle.text = "Add Channel".localized()
        }
    }
    
    private func initChannelType() {
        if channelToEdit != nil {
            initChannelEdittingView()
        }
    }
    
    private func initChannelEdittingView() {
        self.channelId = channelToEdit!.id
        self.avatarLink = channelToEdit!.avatarLink
        self.nameChannel = channelToEdit!.name
        self.aboutChannel = channelToEdit!.aboutChannel
    }
}

//MARK: - Customize
extension NewChannelViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension NewChannelViewController {
    private func showGallery() {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    private func uploadAvatarImage(_ image: UIImage) {
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        // Lưu vào local
        FireStorage.share.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.5)! as NSData, fileName: self.channelId)
        
        // upload lên fire storage
        FireStorage.share.uploadImage(image, directory: fileDirectory) { avatarLink in
            self.avatarLink = avatarLink ?? ""
        }
    }
    
    private func addChannel() {
        let channel = Channel(id: channelId,
                              name: nameChannel,
                              adminId: User.currentId,
                              memberIds: [User.currentId],
                              avatarLink: avatarLink,
                              aboutChannel: aboutChannel
        )
        
        // Lưu vào DB
        FirebaseChannelListener.share.saveChannel(channel)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editChannel() {
        channelToEdit!.name = nameChannel
        channelToEdit!.aboutChannel = aboutChannel
        channelToEdit!.avatarLink = avatarLink
        
        // Lưu vào DB
        FirebaseChannelListener.share.saveChannel(channelToEdit!)
        
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - TableView
extension NewChannelViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = NewChannelCell.loadCell(tableView) as? NewChannelCell else {return UITableViewCell()}
        cell.delegate = self
        if channelToEdit != nil {
            cell.setUpData(channel: channelToEdit!)
        }
        self.cellNewChannel = cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - NewChannelCellDelegate
extension NewChannelViewController: NewChannelCellDelegate {
    func tapAvatar() {
        showGallery()
    }
    
    func changeChannelName(text: String) {
        self.nameChannel = text
    }
    
    func changeAboutChannel(text: String) {
        self.aboutChannel = text
    }
}

//MARK: - GalleryControllerDelegate
extension NewChannelViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first?.resolve(completion: { image in
                if image != nil {
                    // upload ảnh
                    self.uploadAvatarImage(image!)
                    
                    // set lại ảnh trong cell
                    guard let cell = self.cellNewChannel as? NewChannelCell else {return}
                    cell.imgAvatar.image = image?.circleMasked
                } else {
                    ProgressHUD.showFailed("Couldn't select image!".localized())
                }
            })
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
