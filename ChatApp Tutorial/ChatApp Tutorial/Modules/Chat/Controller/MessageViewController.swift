//
//  ChatRoomViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 18/06/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
import KafkaRefresh

//MARK: - Outlet, Override
class MessageViewController: MessagesViewController {
    
    let micButton = InputBarButtonItem()
    
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return view
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.userName ?? "")
    var mkMessages: [MKMessage] = []
    var allLocalsMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    //Listeners - NotificationToken: Một mã thông báo không rõ ràng được trả về từ các phương thức đăng ký các thay đổi đối với Realm.
    var notificationToken: NotificationToken?
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
        loadAllChats()
        listenForNewChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

//MARK: - Action - Obj
extension MessageViewController {
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension MessageViewController {
    private func initComponents() {
        initNavigationBar()
        initMessageCollectionView()
        initMessageInputBar()
    }
    
    private func initNavigationBar() {
        // back button
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        ]
        // title
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        //
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        //
        titleLabel.text = recipientName
    }
    
    // phần tin nhắn bên trên
    private func initMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        // Giá trị Boolean xác định liệu MessagesCollectionView có cuộn đến mục cuối cùng bất cứ khi nào InputTextView bắt đầu chỉnh sửa hay không.
        scrollsToLastItemOnKeyboardBeginsEditing = true
        // Giá trị Boolean xác định liệu MessagesCollectionView có duy trì vị trí hiện tại của nó khi chiều cao của MessageInputBar thay đổi hay không.
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.bindHeadRefreshHandler({
            
        }, themeColor: Defined.defaultColor, refreshStyle: .replicatorTriangle)
    }
    
    // Thanh input bên dưới
    private func initMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.tintColor = Defined.defaultColor
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("plus")
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.tintColor = Defined.defaultColor
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        // Hình ảnh dán có được Kích hoạt không
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        // cập nhật nút bên phải: micro , send
        updateMicroButton(true)
    }
}

//MARK: - Customize
extension MessageViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension MessageViewController {
    //TODO: Gửi tin nhắn
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Double = 0.0) {
        OutgoingMessage.share.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
    }
    
    //TODO: Lấy toàn bộ tin nhắn trong local realm
    private func loadAllChats() {
        // NSPredicate: Định nghĩa về các điều kiện logic được sử dụng để giới hạn tìm kiếm đối với tìm nạp hoặc lọc trong bộ nhớ.
        let predicate = NSPredicate(format: "\(Constants.kChatRoomID) = %@", chatId)
        
        // Lấy message local (sorted "date" : với date là tên cột trong DB)
        allLocalsMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: Constants.kDate, ascending: true)
        
        // Kiểm tra xem trong local có dữ liệu hay không (Trường hợp app bị xóa , sẽ mất hết dữ liệu local -> Cần lấy lại trên database)
        if allLocalsMessages.isEmpty {
            checkForOldChats()
        }
        
        // Bắt sự kiện , cập nhật lại list khi có message mới
        notificationToken = allLocalsMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMessage(self.allLocalsMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .error(let error):
                print("Lỗi khi chèn mới ", error.localizedDescription)
            }
        })
    }
    
    //TODO: Chèn tin nhắn
    private func insertMessages() {
        for message in allLocalsMessages {
            insertMessage(message)
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
    }
    
    //TODO: Cập nhật trạng thái subtitle khi nhập tin nhắn
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "typing..." : ""
    }
    
    //TODO: Cập nhật micron button
    func updateMicroButton(_ show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    //TODO: Lắng nghe khi có cuộc trò chuyện mới
    // Cập nhật khi có tin nhắn mới đến
    private func listenForNewChats() {
        FirebaseMessageListener.share.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    //TODO: Lấy lại đoạn chat cũ trên firebase
    private func checkForOldChats() {
        FirebaseMessageListener.share.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    //TODO: Lấy thời gian của tin nhắn cuối
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalsMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
}

//MARK: - MessagesDataSource
extension MessageViewController: MessagesDataSource {
    //TODO: currentSender
    func currentSender() -> SenderType {
        return currentUser
    }
    
    //TODO: messageForItem
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    //TODO: numberOfSections
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    //TODO: cellTopLabelAttributedText
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let showLoadMore = false
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? Defined.defaultColor : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    //TODO: cellBottomLabelAttributedText
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status.localized() + " " + message.readDate.time() : ""
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            
            return NSAttributedString(string: status, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
}

//MARK: - MessageCellDelegate
extension MessageViewController: MessageCellDelegate {
    
}

//MARK: - MessagesDisplayDelegate
extension MessageViewController: MessagesDisplayDelegate {
    //TODO: configureAvatarView
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
    
    //TODO: textColor
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return Defined.whiteColor
    }
    
    //TODO: backgroundColor
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Defined.defaultColor : MessageDefaults.bubbleColorIncoming
    }
    
    //TODO: messageStyle
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .pointedEdge)
    }
}

//MARK: - MessagesLayoutDelegate
extension MessageViewController: MessagesLayoutDelegate {
    //TODO: cellTopLabelHeight
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 20
        }
        return 0
    }
    
    //TODO: cellBottomLabelHeight
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 18 : 0
    }
    
    //TODO: messageBottomLabelHeight
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != (mkMessages.count - 1) ? 10 : 0
    }
}

//MARK: - InputBarAccessoryViewDelegate
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicroButton(text == "" ? true : false)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                self.messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
