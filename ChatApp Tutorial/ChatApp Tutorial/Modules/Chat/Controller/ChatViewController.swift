//
//  ChatViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 10/06/2021.
//

import UIKit
import RxSwift
import KafkaRefresh

//MARK: - Outlet, Override
class ChatViewController: UIViewController {
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfSearch: DesignableTextField!
    
    let disposeBag = DisposeBag()
    
    var listRecents: [RecentChat] = []
    var filterListRecents: [RecentChat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tfSearch.text = ""
        downloadAllRecent()
    }
    
    @IBAction func btnNewChatTapped(_ sender: Any) {
        guard let vc = RouterType.user.getVc() as? UserViewController else {return}
        vc.isBackButtonHidden = false
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Action, Obj
extension ChatViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension ChatViewController {
    private func initComponents() {
        initLocalizableText()
        initTableView()
        initTextFields()
    }
    
    private func initLocalizableText() {
        lblTitle.text = "Chats".localized()
    }
    
    private func initTableView() {
        ChatCell.registerCellByNib(tblChat)
        tblChat.dataSource = self
        tblChat.delegate = self
        tblChat.separatorInset.left = 0
        tblChat.showsHorizontalScrollIndicator = false
        tblChat.showsVerticalScrollIndicator = false
        tblChat.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblChat.width, height: 0))
        
        tblChat.bindHeadRefreshHandler({
            self.downloadAllRecent()
        }, themeColor: Defined.defaultColor, refreshStyle: .replicatorTriangle)
    }
    
    private func initTextFields() {
        // search textfield
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 15, height: 15))
        tfSearch.leftViewMode = .always
        let image = UIImage(systemName: "magnifyingglass")
        imageView.image = image
        imageView.contentMode = .scaleToFill
        imageView.tintColor = Defined.blackColor
        tfSearch.leftView = imageView
        
        self.tfSearch.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (text) in
                if !text.isEmpty {
                    self.filterListRecents.removeAll()
                    
                    // Trả lại list dựa trên kết quả tìm kiếm
                    self.filterListRecents = self.listRecents.filter({ recent -> Bool in
                        return recent.receiverName!.lowercased().contains(text.lowercased())
                    })
                } else {
                    // Nếu text rỗng trả về full user
                    self.filterListRecents = listRecents
                }
                self.tblChat.reloadData()
            }).disposed(by: disposeBag)
    }
}

//MARK: - Customize
extension ChatViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension ChatViewController {
    private func downloadAllRecent() {
        FirebaseRecentListener.share.downloadRecentChatFromFireStore { allRecents in
            self.tfSearch.text = ""
            self.listRecents = allRecents
            self.filterListRecents = allRecents
            
            DispatchQueue.main.async {
                self.tblChat.reloadData()
                self.tblChat.headRefreshControl.endRefreshing()
                self.view.endEditing(true)
            }
        }
    }
}

//MARK: - TableView
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterListRecents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChatCell.loadCell(tableView) as? ChatCell else {return UITableViewCell()}
        cell.setUpData(recent: filterListRecents[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.chatCellHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recent = listRecents[indexPath.row]
            
            AlertUtil.showAlertConfirm(from: self, with: "Delete".localized() + ":" + " \(recent.receiverName ?? "")" + " ?", message: "") { _ in
                FirebaseRecentListener.share.deleteRecent(recent)
                self.filterListRecents.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = filterListRecents[indexPath.row]
        
        FirebaseRecentListener.share.clearUnreadCounter(recent: recent)
        
        StartChat.share.restartChat(chatRoomId: recent.chatRoomId ?? "", memberIds: recent.memberIds!)
        
        let privateChatRoom = MessageViewController(chatId: recent.chatRoomId ?? "", recipientId: recent.receiverId ?? "", recipientName: recent.receiverName ?? "")
        privateChatRoom.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatRoom, animated: true)
    }
}
