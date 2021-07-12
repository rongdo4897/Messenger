//
//  User.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 01/06/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id: String?
    var userName: String?
    var email: String = ""
    var pushId: String?
    var avatarLink: String?
    var status: String?
    
    // Lấy id hiện tại
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    // Lấy người dùng hiện tại
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let user = LocalResourceRepository.getUserLocally() {
                return user
            }
        }
        return nil
    }
    
    // So sánh 2 user có trùng nhau không
    static func == (lhs: User, rhf: User) ->Bool {
        return lhs.id == rhf.id
    }
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: Constants.kCurrentUser)
    } catch {
        print("Lỗi khi lưu user trên thiết bị", error.localizedDescription)
    }
}
