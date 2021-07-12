//
//  DictionaryExtension.swift
//  FFAdmin
//
//  Created by an.trantuan on 10/8/19.
//  Copyright © 2019 an.trantuan. All rights reserved.
//

import Foundation
import UIKit

// MARK: API for user define
extension Dictionary {
    // swiftlint:disable all
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (String(describing: value)).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }

        return self.isEmpty ? parameterArray.joined(separator: "&") : ("?" + parameterArray.joined(separator: "&"))
    }
    // swiftlint:enable all
}

extension String {
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")

        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    func language() -> String? {
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.language], options: 0)
        tagger.string = self
        return tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil).map { $0.rawValue }
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func getDateFromUTC() -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormater.date(from: self)
        return date
    }

    func getDateFromUTC2() -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormater.date(from: self)
        return date
    }

    func getDate() -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "yyyy-MM-dd"
        let date = dateFormater.date(from: self)
        return date
    }
}

extension Date {
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

protocol Reusable {
    static var reuseID: String {get}
}

extension Reusable {
    static var reuseID: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}

extension UIViewController: Reusable {}

extension UITableView {
    func dequeueReusableCell<T>(ofType cellType: T.Type = T.self, at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID,
                                             for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
}

extension UIStoryboard {
    func instantiateViewController<T>(ofType type: T.Type = T.self) -> T where T: UIViewController {
        guard let viewController = instantiateViewController(withIdentifier: type.reuseID) as? T else {
            fatalError()
        }
        return viewController
    }
}

extension UITextField {

}
