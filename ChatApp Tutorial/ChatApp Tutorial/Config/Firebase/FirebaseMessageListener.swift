//
//  FirebaseMessageListener.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 08/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    static let share = FirebaseMessageListener()
    private init() {}
    
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
}

//MARK: - Add, Update, Delete
extension FirebaseMessageListener {
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try FirebaseReference.shared.firebaseReference(.messages)
                .document(memberId)
                .collection(message.chatRoomId)
                .document(message.id)
                .setData(from: message)
        } catch {
            print("Error saving message", error.localizedDescription)
        }
    }
}

extension FirebaseMessageListener {
    /*
     Lấy lại đoạn chat cũ
     
     - Cấu trúc phân tầng tài liệu message trên firebase
        document -> collection -> ...
     */
    func checkForOldChats(_ documentId: String, collectionId: String) {
        FirebaseReference.shared.firebaseReference(.messages).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Không có tài liệu về đoạn chat cũ")
                return
            }
            
            // Lấy đoạn chat cũ và sắp xếp theo thời gian
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            oldMessages.sort(by: {$0.date < $1.date})
            
            // Lưu lại vào database local
            for message in oldMessages {
                RealmManager.share.saveToRealm(message)
            }
        }
    }
    
    // Lắng nghe đoạn chat mới
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = FirebaseReference.shared.firebaseReference(.messages)
            .document(documentId)
            .collection(collectionId)
            .whereField(Constants.kDate, isGreaterThan: lastMessageDate)
            .addSnapshotListener({ querySnapshot, error in
                guard let snapshot = querySnapshot else {return}
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        let result = Result { try? change.document.data(as: LocalMessage.self) }
                        
                        switch result {
                        case .success(let messageObject):
                            if let message = messageObject {
                                RealmManager.share.saveToRealm(message)
                            } else {
                                print("Tài liệu không tồn tại")
                            }
                        case .failure(let error):
                            print("Lỗi khi giải mã tin nhắn cục bộ: \(error.localizedDescription)")
                        }
                    }
                }
            })
    }
    
    // xóa tiếp tục lắng nghe đoạn chat
    func removeListener() {
        self.newChatListener.remove()
        self.updatedChatListener.remove()
    }
}
