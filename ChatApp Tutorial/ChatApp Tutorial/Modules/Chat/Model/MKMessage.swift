//
//  MKMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import UIKit
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    var messageId: String
    var kind: MessageKind // loại tin nhắn
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType {return mkSender}
    var senderInitials: String
    
    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {
        self.messageId = message.id
        
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
//        switch message.type {
//
//        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
}
