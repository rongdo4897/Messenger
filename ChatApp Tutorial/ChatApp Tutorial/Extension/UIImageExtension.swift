//
//  UIImageExtension.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import Foundation
import UIKit

extension UIImage {
    // chiều dọc
    var isPortrait: Bool {return size.height > size.width}
    // chiều ngang
    var isLandscape: Bool {return size.width > size.height}
    // bề rộng
    var breadth: CGFloat {return min(size.width, size.height)}
    // kích cỡ chiều rộng
    var breadthSize: CGSize {return CGSize(width: breadth, height: breadth)}
    // khung
    var breadthRect: CGRect {return CGRect(origin: .zero, size: breadthSize)}
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else {return nil}
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
