//
//  FirebaseUserListener.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 09/06/2021.
//

import Foundation
import Firebase

class FirebaseUserListener {
    // truy cập phần tử thông qua biến static
    static let shared = FirebaseUserListener()
    
    // hàm khởi tạo dạng private
    private init() {}
}

//MARK: - Login
extension FirebaseUserListener {
    // Đăng nhập users
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            } else {
                completion(error, false)
            }
        }
    }
}

//MARK: - Register
extension FirebaseUserListener {
    // Đăng ký user
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        // Tạo account trên firebase
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            completion(error)
            
            if error == nil {
                // Gửi email xác thực
                authDataResult!.user.sendEmailVerification { error in
                    print("email xác thực được gửi với lỗi: ", error?.localizedDescription ?? "")
                }
                
                // Tạo user và lưu nó
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid,// id được tự động khởi tạo trên firebase
                                    userName: email,
                                    email: email,
                                    pushId: "",
                                    avatarLink: "",
                                    status: Status.available.rawValue)
                    
                    // Lưu vào local
                    LocalResourceRepository.setUserLocally(user: user)
                    
                    // Lưu vào firestore
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    // Lưu user vào firestore database
    func saveUserToFireStore(_ user: User) { // Cái này lên viết thêm completion: error
        do {
            try FirebaseReference.shared.firebaseReference(.user).document(user.id ?? "").setData(from: user)
        } catch {
            print("Lỗi khi thêm user: ", error.localizedDescription)
        }
    }
}

//MARK: - Resend Email, Reset password
extension FirebaseUserListener {
    // Gửi lại mail xác nhận
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }
    
    // Lấy lại mật khẩu
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
}

//MARK: - Logout
extension FirebaseUserListener {
    // Đăng xuất
    func logoutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            
            // Xóa giá trị đã lưu ở user default
            LocalResourceRepository.setUserLocally(user: nil)
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
}

//MARK: - Danh sách user
extension FirebaseUserListener {
    // Lấy thông tin user trên firebase firestore
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        FirebaseReference.shared.firebaseReference(.user).document(userId).getDocument { querySnapShot, error in
            guard let document = querySnapShot else {
                print("No document for user".localized())
                return
            }
            
            // Lấy kết quả trả vế
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let user):
                guard let user = user else {
                    print("Document does not exist".localized())
                    return
                }
                
                LocalResourceRepository.setUserLocally(user: user)
            case .failure(let error):
                print("Error decoding user".localized(), error)
            }
        }
    }
    
    // Lấy toàn bộ danh sách user
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {
        var users: [User] = []
        FirebaseReference.shared.firebaseReference(.user).limit(to: 500).getDocuments { querySnapshot, error in
            guard let document = querySnapshot?.documents else {
                debugPrint("Không có tài liệu danh sách người dùng")
                return
            }
            
            let allUsers = document.compactMap { queryDocumentSnapshot -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    // Lấy danh sách user với id
    func downloadUsersFromFirebaseWithIds(ids: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        var count = 0
        var users: [User] = []
        
        for userId in ids {
            FirebaseReference.shared.firebaseReference(.user).document(userId).getDocument { querySnapshot, error in
                guard let document = querySnapshot else {
                    debugPrint("Không có tài liệu danh sách người dùng với id: \(userId)")
                    return
                }
                
                let user = try? document.data(as: User.self)
                users.append(user!)
                count += 1
                
                if count == ids.count {
                    completion(users)
                }
            }
        }
    }
}
