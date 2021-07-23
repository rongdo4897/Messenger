//
//  PhotoMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/07/2021.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "ic_photoPlace") ?? UIImage()
        self.size = CGSize(width: 240, height: 240)
    }
}
