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
import AVFoundation
import AVKit
import SKPhotoBrowser

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
    
    var gallery: GalleryController!
    
    let realm = try! Realm()
    
    //Listeners - NotificationToken: Một mã thông báo không rõ ràng được trả về từ các phương thức đăng ký các thay đổi đối với Realm.
    var notificationToken: NotificationToken?
    
    // audio
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName: String = ""
    var audioDuration: Date!
    
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
        
        FirebaseRecentListener.share.resetRecentCounter(chatRoomId: chatId)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.share.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
        navigationController?.isNavigationBarHidden = true
    }
}

//MARK: - Action - Obj
extension MessageViewController {
    @objc func backButtonTapped() {
        FirebaseRecentListener.share.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        LocationManager.share.stopUpdating()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func multimediaButtonTapped() {
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera".localized(), style: .default) { _ in
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library".localized(), style: .default) { _ in
            self.showImageGallery(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location".localized(), style: .default) { _ in
            self.shareCurrentLocation()
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
    
    @objc func recordAudio() {
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            
            // Bắt đầu ghi
            AudioRecorder.share.startRecording(fileName: audioFileName)
        case .ended:
            // Kết thúc ghi
            AudioRecorder.share.finishRecording()
            
            if Document.share.fileExistsAtPath(path: audioFileName + ".m4a") {
                // Gửi tin nhắn
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("Không có thư mục audio")
            }
            
            audioFileName = ""
        @unknown default:
            print("không xác định")
        }
    }
}

//MARK: - Các hàm khởi tạo, Setup
extension MessageViewController {
    private func initComponents() {
        initNavigationBar()
        initMessageCollectionView()
        initGestureRecognizer()
        initMessageInputBar()
        initLocation()
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
        
        // load more
        messagesCollectionView.bindHeadRefreshHandler({
            if self.displayingMessagesCount < self.allLocalsMessages.count {
                // Load danh sách tin nhắn tiếp theo
                self.loadMoreMessages(maxNumber: self.maxMessageNumber, minNumber: self.minMessageNumber)
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
            self.messagesCollectionView.headRefreshControl.endRefreshing()
        }, themeColor: Defined.whiteColor, refreshStyle: .replicatorTriangle)
    }
    
    private func initGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
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
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        // Hình ảnh dán có được Kích hoạt không
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        // cập nhật nút bên phải: micro , send
        updateMicroButton(true)
    }
    
    private func initLocation() {
        LocationManager.share.startUpdating()
    }
}

//MARK: - Customize
extension MessageViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng - send , load all message
extension MessageViewController {
    // Gửi tin nhắn
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.share.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])
    }
    
    // Lấy toàn bộ tin nhắn trong local realm
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
    
    // Lấy lại đoạn chat cũ trên firebase
    private func checkForOldChats() {
        FirebaseMessageListener.share.checkForOldChats(User.currentId, collectionId: chatId)
    }
}

//MARK: - Các hàm chức năng - insert message , load more
extension MessageViewController {
    // Chèn tin nhắn
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
    
    // Load more messages
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
    
    // Đánh dấu tin nhắn đã đọc
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId && localMessage.status != Constants.kRead {
            FirebaseMessageListener.share.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recipientId])
        }
    }
}

//MARK: - Các hàm chức năng - update message
extension MessageViewController {
    // Cập nhật trạng thái đã đọc cho tin nhắn
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
}

//MARK: - Các hàm chức năng - typing
extension MessageViewController {
    // Cập nhật typing khi nhập tin nhắn
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
    
    func updateGifIndicator(_ show: Bool) {
        typingGifImageView.isHidden = !show
    }
}
//MARK: - Các hàm chức năng - Listener firebase
extension MessageViewController {
    // Xóa toàn bộ listener khi ấn nút back
    private func removeListeners() {
        FirebaseTypingListener.share.removeTypingListener()
        FirebaseMessageListener.share.removeListener()
    }
    
    // Lắng nghe khi có cuộc trò chuyện mới
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
    
    // Lấy thời gian của tin nhắn cuối
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalsMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
}

//MARK: - Các hàm chức năng - khác
extension MessageViewController {
    // Cập nhật micron button
    private func updateMicroButton(_ show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    // gallery
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        gallery.modalPresentationStyle = .fullScreen
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    private func shareCurrentLocation() {
        if let  _ = LocationManager.share.currentLocation {
            self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: Constants.kLocation)
        } else {
            print("no access to Location")
        }
    }
}

//MARK: - MessagesDataSource
extension MessageViewController: MessagesDataSource {
    // currentSender
    func currentSender() -> SenderType {
        return currentUser
    }
    
    // messageForItem
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    // numberOfSections
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    // cellTopLabelAttributedText
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
    
    // cellBottomLabelAttributedText
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
    // tap image
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                
                self.present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    //
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            // kiểm tra chạm loại tin nhắn bản đồ
            if mkMessage.locationItem != nil {
                guard let vc = RouterType.map.getVc() as? MapViewController else {return}
                vc.location = mkMessage.locationItem!.location
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}

//MARK: - MessagesDisplayDelegate
extension MessageViewController: MessagesDisplayDelegate {
    // configureAvatarView
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
    
    // textColor
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Defined.whiteColor : Defined.defaultColor
    }
    
    // backgroundColor
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Defined.defaultColor : Defined.whiteColor
    }
    
    // messageStyle
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

//MARK: - MessagesLayoutDelegate
extension MessageViewController: MessagesLayoutDelegate {
    // cellTopLabelHeight
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            if indexPath.section == 0 && allLocalsMessages.count > displayingMessagesCount {
                return 40
            }
            return 20
        }
        return 0
    }
    
    // cellBottomLabelHeight
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 18 : 0
    }
    
    // messageBottomLabelHeight
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

//MARK: - GalleryControllerDelegate
extension MessageViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        self.dismiss(animated: true, completion: nil)
    }
}
