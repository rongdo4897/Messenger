//
//  Constants.swift
//  IVM
//
//  Created by an.trantuan on 6/26/20.
//  Copyright © 2020 an.trantuan. All rights reserved.
//

import UIKit

class Constants {
    // storyboard
    static let main: String = "Main"
    static let login: String = "Login"
    static let tabbar: String = "Tabbar"
    static let chat: String = "Chat"
    static let channel: String = "Channel"
    static let user: String = "User"
    static let setting: String = "Setting"
    
    // user deffault
    static let kCurrentUser: String = "CurrentUser"
    static let kChatRoomID: String = "chatRoomId"
    static let kSenderID: String = "senderId"
    static let kSent: String = "sent"
    static let kRead: String = "read"
    static let kStatus: String = "status"
    
    static let kText: String = "text"
    static let kPhoto: String = "photo"
    static let kVideo: String = "video"
    static let kAudio: String = "audio"
    static let kLocation: String = "location"
    
    static let kDate: String = "date"
    static let kReadDate: String = "date"
    
    static let kNumberOfMessage: Int = 12
    
    
    // heightCell
    static let chatCellHeight: CGFloat = 100
    
    // File storage
    static let fireStorageReference = "gs://messenger-52f6d.appspot.com"
}

class Defined {
    static let devideId: String = UIDevice.current.identifierForVendor!.uuidString
    static let devideName: String = UIDevice.current.name
    // color
    static let whiteColor: UIColor = UIColor.white
    static let blackColor: UIColor = UIColor.black
    static let defaultColor: UIColor = UIColor.colorFromHexString(hex: "3498DB")
}
