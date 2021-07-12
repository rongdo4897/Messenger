//
//  LocalMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import RealmSwift

// Lưu tin nhắn vào local
class LocalMessage: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var chatRoomId: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var senderName: String = ""
    @objc dynamic var senderId: String = ""
    @objc dynamic var senderInitials: String = "" // Chữ cái đầu tiên của tên
    @objc dynamic var readDate: Date = Date()
    @objc dynamic var type: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var audioUrl: String = ""
    @objc dynamic var videoUrl: String = ""
    @objc dynamic var pictureUrl: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var audioDuration: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
