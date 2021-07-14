//
//  RecentChat.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 17/06/2021.
//

import Foundation
import FirebaseFirestoreSwift

// Cấu trúc tham gia chat của ng dùng
struct RecentChat: Codable {
    var id: String?
    var chatRoomId: String?
    var senderId: String?
    var senderName: String?
    var receiverId: String?
    var receiverName: String?
    @ServerTimestamp var date = Date()
    var memberIds: [String]?
    var lastMessage: String = ""
    var unreadCounter: Int = 0
    var avatarLink: String?
}
