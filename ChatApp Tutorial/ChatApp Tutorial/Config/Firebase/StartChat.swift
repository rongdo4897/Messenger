//
//  StartChat.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 17/06/2021.
//

import Foundation
import Firebase

class StartChat {
    static let share = StartChat()
    private init() {}
}

extension StartChat {
    // Bắt đầu chat
    func startChat(user1: User, user2: User) -> String {
        let chatRoomId = chatRoomIdFrom(user1Id: user1.id ?? "", user2Id: user2.id ?? "")
        
        createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
        return chatRoomId
    }
    
    // Bắt đầu lại chat
    func restartChat(chatRoomId: String, memberIds: [String]) {
        FirebaseUserListener.shared.downloadUsersFromFirebaseWithIds(ids: memberIds) { users in
            if users.count > 0 {
                self.createRecentItems(chatRoomId: chatRoomId, users: users)
            }
        }
    }
    
    // Tạo chat gần đây
    func createRecentItems(chatRoomId: String, users: [User]) {
        var memberIdsToCreateRecent = [users.first!.id ?? "", users.last!.id ?? ""]
        
        FirebaseReference.shared.firebaseReference(.recent).whereField(Constants.kChatRoomID, isEqualTo: chatRoomId).getDocuments { querySnapShot, error in
            guard let snapshot = querySnapShot else {return}
            
            if !snapshot.isEmpty {
                memberIdsToCreateRecent = self.removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            }
            
            for userId in memberIdsToCreateRecent {
                // Người gửi
                let senderUser = userId == User.currentId ? User.currentUser! : self.getReceiverFrom(users: users)
                // Người nhận
                let receiverUser = userId == User.currentId ? self.getReceiverFrom(users: users) : User.currentUser!
                
                // Khởi tạo đối tượng
                let recentObject = RecentChat(id: UUID().uuidString,
                                              chatRoomId: chatRoomId,
                                              senderId: senderUser.id,
                                              senderName: senderUser.userName,
                                              receiverId: receiverUser.id,
                                              receiverName: receiverUser.userName,
                                              date: Date(),
                                              memberIds: [senderUser.id ?? "", receiverUser.id ?? ""],
                                              lastMessage: "",
                                              unreadCounter: 0,
                                              avatarLink: receiverUser.avatarLink)
                
                // Lưu đối tượng vào firebase firestore
                FirebaseRecentListener.share.saveRecent(recentObject)
            }
        }
    }
    
    // Xóa thành viên có gần đây
    func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
        var memberIdsToCreateRecent = memberIds
        
        for recentData in snapshot.documents {
            let currentRecent = recentData.data() as Dictionary
            
            if let currentUserId = currentRecent[Constants.kSenderID] {
                if memberIdsToCreateRecent.contains(currentUserId as! String) {
                    memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
                }
            }
        }
        
        return memberIdsToCreateRecent
    }
    
    // Lấy id phòng chat giữa 2 người
    func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
        var chatRoomId = ""
        
        let value = user1Id.compare(user2Id).rawValue
        chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
        
        return chatRoomId
    }
    
    // Lấy người nhận (xóa người dùng hiện tại khỏi danh sách)
    func getReceiverFrom(users: [User]) -> User {
        var allUsers = users
        allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
        
        return allUsers.first!
    }
}
