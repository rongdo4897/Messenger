//
//  FirebaseTypingListener.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 12/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// Lớp này lắng nghe khi người khác nhập văn bản , ...
class FirebaseTypingListener {
    static let share = FirebaseTypingListener()
    
    private init() {}
    
    // Đại diện cho một người nghe có thể bị xóa bằng cách gọi remove.
    var typingListener: ListenerRegistration!
}

extension FirebaseTypingListener {
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingListener = FirebaseReference.shared.firebaseReference(.typing).document(chatRoomId).addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference.shared.firebaseReference(.typing).document(chatRoomId).setData([User.currentId: false])
            }
        })
    }
    
    func saveTypingCounter(typing: Bool, chatRoomId: String) {
        FirebaseReference.shared.firebaseReference(.typing).document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}
