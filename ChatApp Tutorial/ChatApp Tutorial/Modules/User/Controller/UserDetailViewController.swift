//
//  UserDetailViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 16/06/2021.
//

import UIKit

//MARK: - Outlet, Override
class UserDetailViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblDetail: UITableView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action - Obj
extension UserDetailViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension UserDetailViewController {
    private func initComponents() {
        initTableView()
        initData()
    }
    
    private func initTableView() {
        UserDetailCell.registerCellByNib(tblDetail)
        tblDetail.dataSource = self
        tblDetail.delegate = self
        tblDetail.separatorInset.left = 0
        tblDetail.showsVerticalScrollIndicator = true
        tblDetail.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblDetail.width, height: 0))
    }
    
    private func initData() {
        lblTitle.text = user?.userName ?? ""
    }
}

//MARK: - Customize
extension UserDetailViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension UserDetailViewController {
    
}

//MARK: - TableView
extension UserDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = UserDetailCell.loadCell(tableView) as? UserDetailCell else {return UITableViewCell()}
        cell.delegate = self
        cell.setUpData(user: self.user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - UserDetailCellDelegate
extension UserDetailViewController: UserDetailCellDelegate {
    func tapViewChat(user: User) {
        let chatId = StartChat.share.startChat(user1: User.currentUser!, user2: user)
        
        let privateChatRoom = MessageViewController(chatId: chatId, recipientId: user.id ?? "", recipientName: user.userName ?? "")
        privateChatRoom.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatRoom , animated: true)
    }
}
