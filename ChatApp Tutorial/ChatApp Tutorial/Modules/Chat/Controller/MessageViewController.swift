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
    
    let typingGifImageView: UIImageView = {
        let gifImage = UIImage.gifImageWithName("threedots")
        let imageView = UIImageView(frame: CGRect(x: 5, y: 22, width: 30, height: 20))
        imageView.backgroundColor = .clear
        imageView.image = gifImage
        return imageView
    }()
    
    private var chatId = "" // id phòng chat
    private var recipientId = "" // id người nhận
    private var recipientName = "" // tên người nhận
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.userName ?? "") // người dùng hiện tại
    var mkMessages: [MKMessage] = [] // data hiển thị lên view
    var allLocalsMessages: Results<LocalMessage>! // Toàn bộ data tin nhắn trong local
    
    var displayingMessagesCount = 0 // Số lượng tin nhắn mới nhất đc thêm vào
    // oldest-----min-----------max min-----------max min-----------max lastest
    var maxMessageNumber = 0 // Số tin nhắn tối đa
    var minMessageNumber = 0 // Số tin nhắn tối thiểu
    
    var typingCounter = 0
    
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
        listenForReadStatusChange()
        createTypingObserver()
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
        FirebaseRecentListener.share.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func multimediaButtonTapped() {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera".localized(), style: .default) { _ in
            print("show camera")
        }
        let shareMedia = UIAlertAction(title: "Library".localized(), style: .default) { _ in
            print("show library")
        }
        let shareLocation = UIAlertAction(title: "Share Location".localized(), style: .default) { _ in
            print("show location")
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancel)
        
        present(optionMenu, animated: true, completion: nil)
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
//        leftBarButtonView.addSubview(subTitleLabel)
        leftBarButtonView.addSubview(typingGifImageView)
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

        // Background
        let imageBackground = UIImage(named: "ic_ChatBackground2")
        let imageView = UIImageView(image: imageBackground)
        imageView.contentMode = .scaleAspectFill
        messagesCollectionView.backgroundView = imageView
        
        // Giá trị Boolean xác định liệu MessagesCollectionView có cuộn đến mục cuối cùng bất cứ khi nào InputTextView bắt đầu chỉnh sửa hay không.
        scrollsToLastItemOnKeyboardBeginsEditing = true
        // Giá trị Boolean xác định liệu MessagesCollectionView có duy trì vị trí hiện tại của nó khi chiều cao của MessageInputBar thay đổi hay không.
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.bindHeadRefreshHandler({
            if self.displayingMessagesCount < self.allLocalsMessages.count {
                // Load danh sách tin nhắn tiếp theo
                self.loadMoreMessages(maxNumber: self.maxMessageNumber, minNumber: self.minMessageNumber)
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
            self.messagesCollectionView.headRefreshControl.endRefreshing()
        }, themeColor: Defined.whiteColor, refreshStyle: .replicatorTriangle)
    }
    
    // Thanh input bên dưới
    private func initMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.tintColor = Defined.defaultColor
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(multimediaButtonTapped)))
        
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
        // maxMessageNumber: Tổng số lượng tin nhắn - số lượng tin nhắn đc thêm vào
        maxMessageNumber = allLocalsMessages.count - displayingMessagesCount
        // minMessageNumber: Giới hạn dưới của số tin nhắn đc hiển thị với maxMessageNumber
        minMessageNumber = maxMessageNumber - Constants.kNumberOfMessage
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalsMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        
        // Số lượng tin nhắn đc thêm vào tự động tăng khi có tin nhắn mới
        displayingMessagesCount += 1
    }
    
    // Thêm tin nhắn cũ hơn
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        
        // Số lượng tin nhắn đc thêm vào tự động tăng khi có tin nhắn mới
        displayingMessagesCount += 1
    }
    
    //TODO: Load more messages
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - Constants.kNumberOfMessage
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalsMessages[i])
        }
    }
    
    //TODO: Cập nhật trạng thái đã đọc cho tin nhắn
    private func updateMessage(_ localMessage: LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                // Lưu lại tin nhắn vào db local
                RealmManager.share.saveToRealm(localMessage)
                
                if mkMessages[index].status == Constants.kRead {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId && localMessage.status != Constants.kRead {
            FirebaseMessageListener.share.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recipientId])
        }
    }
    
    //TODO: Cập nhật typing khi nhập tin nhắn
    func createTypingObserver() {
        FirebaseTypingListener.share.createTypingObserver(chatRoomId: chatId) { isTyping in
            DispatchQueue.main.async {
                self.updateGifIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        typingCounter += 1
        
        FirebaseTypingListener.share.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Dừng bộ đếm
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        
        if typingCounter == 0 {
            FirebaseTypingListener.share.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    private func removeListeners() {
        FirebaseTypingListener.share.removeTypingListener()
        FirebaseMessageListener.share.removeListener()
    }
    
    func updateGifIndicator(_ show: Bool) {
        typingGifImageView.isHidden = !show
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
    
    private func listenForReadStatusChange() {
        FirebaseMessageListener.share.listenForReadStatusChange(User.currentId, collectionId: chatId) { updateMessage in
            if updateMessage.status != Constants.kSent {
                self.updateMessage(updateMessage)
            }
        }
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
            var showLoadMore = false
            if indexPath.section == 0 && allLocalsMessages.count > displayingMessagesCount {
                showLoadMore = true
            }
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.boldSystemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = Defined.whiteColor
            
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
        return isFromCurrentSender(message: message) ? Defined.whiteColor : Defined.defaultColor
    }
    
    //TODO: backgroundColor
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Defined.defaultColor : Defined.whiteColor
    }
    
    //TODO: messageStyle
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

//MARK: - MessagesLayoutDelegate
extension MessageViewController: MessagesLayoutDelegate {
    //TODO: cellTopLabelHeight
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            if indexPath.section == 0 && allLocalsMessages.count > displayingMessagesCount {
                return 40
            }
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
        if text != "" {
            typingIndicatorUpdate()
        }
        
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
