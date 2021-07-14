//
//  FirebaseRecentListener.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 17/06/2021.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    static let share = FirebaseRecentListener()
    private init() {}
}

extension FirebaseRecentListener {
    // Thêm đoạn chat giữa 2 người
    func saveRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference.shared.firebaseReference(.recent).document(recent.id ?? "").setData(from: recent)
        } catch {
            print("Lỗi khi thêm đoạn chat gần đây: ", error.localizedDescription)
        }
    }
    
    // Lấy danh sách người trò chuyện
    func downloadRecentChatFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        FirebaseReference.shared.firebaseReference(.recent).whereField(Constants.kSenderID, isEqualTo: User.currentId).addSnapshotListener { querySnapshot, error in
            var recentChats: [RecentChat] = []
            
            guard let document = querySnapshot?.documents else {
                print("Không có tài liệu cho đoạn chat gần đây")
                return
            }
            
            // Truy cập vào document trên firestore và chuyển nó thành đối tượng
            let allRecents = document.compactMap { queryDocumentSnapshot -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            // Bỏ qua những đối tượng không có tin nhắn cuối cùng
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            // Sắp xếp lại theo thời gian
            recentChats.sort { c1, c2 in
                return c1.date! > c2.date!
            }
            
            completion(recentChats)
        }
    }
    
    // Xóa đoạn chat
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference.shared.firebaseReference(.recent).document(recent.id!).delete()
    }
    
    // Xóa bộ đếm chưa đọc
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        // Lưu lại vào firestore
        self.saveRecent(newRecent)
    }
    
    // đặt lại bộ đếm gần đây
    func resetRecentCounter(chatRoomId: String) {
        FirebaseReference.shared.firebaseReference(.recent)
            .whereField(Constants.kChatRoomID, isEqualTo: chatRoomId)
            .whereField(Constants.kSenderID, isEqualTo: User.currentId)
            .getDocuments { querySnapshot, error in
                guard let document = querySnapshot?.documents else {
                    print("Không có tài liệu đoạn chat gần đây")
                    return
                }
                
                let allRecents = document.compactMap { queryDocumentSnapshot -> RecentChat? in
                    return try? queryDocumentSnapshot.data(as: RecentChat.self)
                }
                
                if allRecents.count > 0 {
                    self.clearUnreadCounter(recent: allRecents.first!)
                }
            }
    }
    
    //TODO: Cập nhật tin nhắn cuối cùng
    func updateRecents(chatRoomId: String, lastMessage: String) {
        FirebaseReference.shared.firebaseReference(.recent)
            .whereField(Constants.kChatRoomID, isEqualTo: chatRoomId)
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Không có tài liệu cập nhật gần đây")
                    return
                }
                
                let allRecents = documents.compactMap { queryDocumentSnapshot -> RecentChat? in
                    return try? queryDocumentSnapshot.data(as: RecentChat.self)
                }
                
                for recentChat in allRecents {
                    self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
                }
            }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
}
