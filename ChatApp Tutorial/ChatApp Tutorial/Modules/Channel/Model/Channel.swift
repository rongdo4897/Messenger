//
//  Channel.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 23/07/2021.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Channel: Codable {
    var id: String = ""
    var name: String = ""
    var adminId: String = ""
    var memberIds: [String] = [""]
    var avatarLink: String = ""
    var aboutChannel: String = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    /*
     -- Viết trong enum: Chọn thuộc tính để mã hóa và giải mã
     
     -- CodingKey:  Một loại có thể được sử dụng như một khóa để encoding và decoding.
     
     -- Chi tiết: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
     */
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"
    }
}
