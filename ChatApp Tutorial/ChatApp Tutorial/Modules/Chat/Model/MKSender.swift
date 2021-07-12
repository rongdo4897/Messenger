//
//  MKSender.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 21/06/2021.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    static let bubbleColorOutgoing = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let bubbleColorIncoming = UIColor(red: 230.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
}
