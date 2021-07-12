//
//  FCollectionReference.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 09/06/2021.
//

import Foundation
import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case user = "User"
    case recent = "Recent"
    case messages = "Messages"
    case typing = "Typing"
}


class FirebaseReference {
    static let shared = FirebaseReference()
    
    private init() {}
    
    /*
     Đối tượng `FIRCollectionReference` có thể được sử dụng để thêm tài liệu,
     lấy tham chiếu tài liệu và truy vấn tài liệu (sử dụng các phương thức được kế thừa từ` FIRQuery`).
     */
    func firebaseReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
        return Firestore.firestore().collection(collectionReference.rawValue)
    }
}
