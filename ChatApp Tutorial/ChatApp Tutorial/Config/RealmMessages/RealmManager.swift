//
//  RealmManager.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import RealmSwift

class RealmManager {
    static let share = RealmManager()
    
    let realm = try! Realm()
    
    private init() {}
}

extension RealmManager {
    func saveToRealm<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("Lỗi khi lưu đối tượng vào realm: ", error.localizedDescription)
        }
    }
}
