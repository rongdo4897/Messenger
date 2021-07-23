//
//  AudioMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 22/07/2021.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.duration = duration
        self.size = CGSize(width: 160, height: 35)
    }
}
