//
//  OutgoingMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

//MARK: - Tin nhắn gửi đi
class OutgoingMessage {
    static let share = OutgoingMessage()
    
    private init() {}
}

extension OutgoingMessage {
    func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
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
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        //TODO: Gửi thông báo
        FirebaseRecentListener.share.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
        //TODO: Cập nhật gần đây
        
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

//MARK: - send message type
extension OutgoingMessage {
    // tin nhắn văn bản
    func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
        message.message = text
        message.type = Constants.kText
        
        sendMessage(message: message, memberIds: memberIds)
    }
    
    // tin nhắn hình ảnh
    func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {
        message.message = "[* - Picture - *]"
        message.type = Constants.kPhoto
        
        // file name
        let fileName = Date().stringDate()
        let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
        
        // Lưu image vào local
        FireStorage.share.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
        
        // Lưu image vào file storage
        FireStorage.share.uploadImage(photo, directory: fileDirectory) { imageUrl in
            if imageUrl != nil {
                message.pictureUrl = imageUrl!
                self.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
    
    // tin nhắn video
    func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]) {
        message.message = "[* - Video - *]"
        message.type = Constants.kVideo
        
        // file name
        let fileName = Date().stringDate()
        let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg" // Đường dẫn ảnh minh họa
        let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
        
        let editor = VideoEditor()
        editor.process(video: video) { processedVideo, videoUrl in
            if let tempPath = videoUrl {
                let thumbnailImage = videoThumbnail(videoUrl: tempPath)
                
                // Lưu vào local
                FireStorage.share.saveFileLocally(fileData: thumbnailImage.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
                
                // Lưu vào firestorage
                FireStorage.share.uploadImage(thumbnailImage, directory: thumbnailDirectory) { imageUrl in
                    if imageUrl != nil {
                        let videoData = NSData(contentsOfFile: tempPath.path)
                        // Lưu local
                        FireStorage.share.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                        // Lưu firestorage
                        FireStorage.share.uploadVideo(videoData!, directory: videoDirectory) { videoUrl in
                            message.pictureUrl = imageUrl ?? ""
                            message.videoUrl = videoUrl ?? ""
                            
                            self.sendMessage(message: message, memberIds: memberIds)
                        }
                    }
                }
            }
        }
    }
    
    // Tin nhắn vị trí
    func sendLocationMessage(message: LocalMessage, memberIds: [String]) {
        let currentLocation = LocationManager.share.currentLocation
        message.message = "[* - Location - *]"
        message.type = Constants.kLocation
        message.latitude = currentLocation?.latitude ?? 0.0
        message.longitude = currentLocation?.longitude ?? 0.0
        
        self.sendMessage(message: message, memberIds: memberIds)
    }
    
    // Tin nhắn âm thanh
    func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String]) {
        message.message = "[* - Audio - *]"
        message.type = Constants.kAudio
        
        let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
        
        FireStorage.share.uploadAudio(audioFileName, directory: fileDirectory) { audioUrl in
            if audioUrl != nil {
                message.audioUrl = audioUrl!
                message.audioDuration = Double(audioDuration)
                
                self.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}
