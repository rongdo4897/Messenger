//
//  IncomingMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 09/07/2021.
//

import Foundation
import MessageKit
import CoreLocation

//MARK: - Tin nhắn đến
class IncomingMessage {
    var messageViewController: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        self.messageViewController = _collectionView
    }
}

extension IncomingMessage {
    // Tạo tin nhắn
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        return mkMessage
    }
}
