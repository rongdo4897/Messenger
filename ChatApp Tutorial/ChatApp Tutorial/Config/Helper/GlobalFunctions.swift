//
//  GlobalFunctions.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import Foundation
import UIKit
import AVFoundation

// Lấy phần của chuỗi từ vị trí tìm được
func fileNameFrom(fileUrl: String) -> String {
    let name = ((fileUrl.components(separatedBy: "_").last)?.components(separatedBy: "?").first!)?.components(separatedBy: ".").first!
    return name!
}

// Định dạng lại thời gian
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

// ảnh thu nhỏ của video
func videoThumbnail(videoUrl: URL) -> UIImage {
    // AVURLAsset: Một lớp con nội dung được sử dụng để khởi tạo nội dung từ URL cục bộ hoặc từ xa.
    let asset = AVURLAsset(url: videoUrl, options: nil)
    // AVAssetImageGenerator: Một đối tượng tạo hình thu nhỏ hoặc hình ảnh xem trước của nội dung video.
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    // CMTimeMakeWithSeconds: Tạo CMTime từ số giây Float64 và khoảng thời gian ưa thích.
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    // thời gian thực tế
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print("Lỗi khi tạo ảnh thu nhỏ video: ", error.localizedDescription)
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(named: "ic_photoPlace") ?? UIImage()
    }
}
