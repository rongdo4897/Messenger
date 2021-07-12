//
//  GlobalFunctions.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import Foundation

// Lấy phần của chuỗi từ vị trí tìm được
func fileNameFrom(fileUrl: String) -> String {
    let name = ((fileUrl.components(separatedBy: "_").last)?.components(separatedBy: "?").first!)?.components(separatedBy: ".").first!
    return name!
}

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    
    if seconds < 60 {
        elapsed = "Just now".localized()
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins ago" : "min ago"
        elapsed = "\(minutes) \(minText.localized())"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "hours ago" : "hour ago"
        elapsed = "\(hours) \(hourText.localized())"
    } else {
        elapsed = "\(date.longDate(type: .day)) \(date.longDate(type: .month).localized()) \(date.longDate(type: .year))"
    }
    
    return elapsed
}
