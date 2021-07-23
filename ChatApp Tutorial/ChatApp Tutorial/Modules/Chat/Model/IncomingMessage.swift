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
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        self.messageCollectionView = _collectionView
    }
}

extension IncomingMessage {
    // Tạo tin nhắn
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        // Ảnh
        if localMessage.type == Constants.kPhoto {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FireStorage.share.downloadImage(imageUrl: localMessage.pictureUrl) { image in
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        // Video
        if localMessage.type == Constants.kVideo {
            // download image
            FireStorage.share.downloadImage(imageUrl: localMessage.pictureUrl) { thumbNailImage in
                // download video
                FireStorage.share.downloadVideo(videoLink: localMessage.videoUrl) { isReadyToPlay, fileName in
                    let videoUrl = URL(fileURLWithPath: Document.share.fileInDocumentDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videoUrl)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                
                mkMessage.videoItem?.image = thumbNailImage
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        // Location
        if localMessage.type == Constants.kLocation {
            let location = CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude)
            let locationItem = LocationMessage(location: location)
            
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
            
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        // Audio
        if localMessage.type == Constants.kAudio {
            let audioItem = AudioMessage(duration: Float(localMessage.audioDuration))
            
            mkMessage.audioItem = audioItem
            mkMessage.kind = MessageKind.audio(audioItem)
            
            FireStorage.share.downloadAudio(audioLink: localMessage.audioUrl) { fileName in
                let audioUrl = URL(fileURLWithPath: Document.share.fileInDocumentDirectory(fileName: fileName))
                
                mkMessage.audioItem?.url = audioUrl
            }
            
            self.messageCollectionView.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
}
