//
//  ExtensionString.swift
//  IVM
//
//  Created by an.trantuan on 7/13/20.
//  Copyright © 2020 an.trantuan. All rights reserved.
//

import UIKit
// swiftlint:disable all
extension String {
    func createDateFromTimeStamp() -> Date {
        if let intvalue = Double(self) {
            let date = NSDate(timeIntervalSince1970: intvalue)
            return date as Date
        } else {
            return Date()
        }
    }

   func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}

extension String {
    func toDictionary() -> NSDictionary {
        let blankDict : NSDictionary = [:]
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return blankDict
    }
}

extension String {
    var isNumeric : Bool {
        let characters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
}

extension UITextField {
    func setRightImage(imageName: String) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleToFill
        self.rightView = imageView
        imageView.changeTintColor(color: Defined.defaultColor)
        self.rightViewMode = .always
    }
    
    func setUpRightImage(name: String) {
        let imageView = UIImageView(frame: CGRect(x: 15.0, y: 18.0, width: 15, height: 15))
        imageView.image = UIImage(named: name)
        imageView.changeTintColor(color: .gray)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        view.addSubview(imageView)
        self.rightViewMode = .always
        self.rightView = view
    }
}

extension String {
    func localToUTC(incomingFormat: String, outGoingFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = incomingFormat
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = outGoingFormat
        
        return dateFormatter.string(from: dt ?? Date())
    }
    func UTCToLocal(incomingFormat: String, outGoingFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = incomingFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = outGoingFormat
        
        return dateFormatter.string(from: dt ?? Date())
    }
}
