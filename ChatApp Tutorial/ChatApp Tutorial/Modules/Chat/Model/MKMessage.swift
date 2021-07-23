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
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    
    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {
        self.messageId = message.id
        
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case Constants.kText:
            self.kind = MessageKind.text(message.message)
        case Constants.kPhoto:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        case Constants.kVideo:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
        case Constants.kLocation:
            let location = CLLocation(latitude: message.latitude, longitude: message.longitude)
            let locationItem = LocationMessage(location: location)
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
        case Constants.kAudio:
            let audioItem = AudioMessage(duration: 2.0)
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        default:
            self.kind = MessageKind.text(message.message)
            print("unknow message type")
        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
}
