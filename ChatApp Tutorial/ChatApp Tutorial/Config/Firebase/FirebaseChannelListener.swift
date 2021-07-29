//
//  FirebaseChannelListener.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 26/07/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseChannelListener {
    static let share = FirebaseChannelListener()
    
    var channelListener: ListenerRegistration!
    
    private init() {}
}

//MARK: - Lấy dữ liệu
extension FirebaseChannelListener {
    // Nhóm của bản thân
    func downloadUserChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        channelListener = FirebaseReference.shared.firebaseReference(.channel).whereField(Constants.kAdminId, isEqualTo: User.currentId).addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Không có tài liệu nhóm người dùng")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            
            completion(allChannels)
        })
    }
    
    // Nhóm đã đăng ký ( trong memberIds chứa id của bản thân )
    func downloadSubscribedChannels(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        channelListener = FirebaseReference.shared.firebaseReference(.channel).whereField(Constants.kMemberIds, arrayContains: User.currentId).addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Không có tài liệu nhóm đã đăng ký")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            
            completion(allChannels)
        })
    }
    
    // Lấy toàn bộ nhóm
    func downloadAllChannels(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        FirebaseReference.shared.firebaseReference(.channel).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Không có tài liệu toàn bộ nhóm")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels = self.removeSubscribedChannel(allChannels)
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            
            completion(allChannels)
        }
    }
}

//MARK: - Thêm , sửa , xóa
extension FirebaseChannelListener {
    // Lưu nhóm: Dùng cho add và edit
    func saveChannel(_ channel: Channel) {
        do {
            try FirebaseReference.shared.firebaseReference(.channel).document(channel.id).setData(from: channel)
        } catch {
            print("Lỗi khi lưu nhóm: ", error.localizedDescription)
        }
    }
    
    // Xóa nhóm
    func deleteChannel(_ channel: Channel) {
        FirebaseReference.shared.firebaseReference(.channel).document(channel.id).delete()
    }
    
    // Xoá các nhóm đã đăng kí khỏi danh sách tổng số nhóm
    func removeSubscribedChannel(_ allChannels: [Channel]) -> [Channel] {
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    // Xóa kết nối cập nhật liên tục từ firebase
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
