//
//  OutgoingMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

//MARK: - Tin nhắn gửi đi
class OutgoingMessage {
    static let share = OutgoingMessage()
    
    private init() {}
}

extension OutgoingMessage {
    func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Double = 0.0, location: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id ?? ""
        message.senderName = currentUser.userName ?? ""
        message.senderInitials = String((currentUser.userName ?? "").first!)
        message.date = Date()
        message.status = Constants.kSent
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        //TODO: Gửi thông báo
        
        //TODO: Cập nhật gần đây
        
    }
    
    // Gửi tin nhắn văn bản
    func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
        message.message = text
        message.type = Constants.kText
        
        sendMessage(message: message, memberIds: memberIds)
    }
    
    // Lưu vào database
    private func sendMessage(message: LocalMessage, memberIds: [String]) {
        // Lưu vào database local
        RealmManager.share.saveToRealm(message)
        
        // Lưu vào database firebase
        for memberId in memberIds {
            FirebaseMessageListener.share.addMessage(message, memberId: memberId)
        }
    }
}
