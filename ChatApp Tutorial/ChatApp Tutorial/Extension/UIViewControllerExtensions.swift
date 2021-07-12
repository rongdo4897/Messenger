//
//  UIViewControllerExtensions.swift
//  SmartTA
//
//  Created by THUY Nguyen Duong Thu on 26/11/2020.
//  Copyright © 2020 vti. All rights reserved.
//

import UIKit

extension UIViewController {
    // get week range
    func getDayRange(weekNo: Int, for date: Date) -> [Date] {
        var list = [Date]()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "vi_VN")
        calendar.firstWeekday = 2
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let startComponents = DateComponents(weekOfYear: weekNo, yearForWeekOfYear: year)
        var startDate = calendar.date(from: startComponents)!
        for _ in 1...7 {
            list.append(startDate)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        }
        return list
    }
    func customizeButtons(buttons: [UIView]) {
        buttons.forEach { (b) in
            b.layer.cornerRadius = 6
            b.layer.borderWidth = 0.3
            b.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
    }

    func addShadow(views: [UIView]) {
        views.forEach { (v) in
            v.addShadow()
        }
    }

    func addTopBottomLines(views: [UIView]) {
        views.forEach { (v) in
            v.addLineToView(position: .LINE_POSITION_BOTTOM)
            v.addLineToView(position: .LINE_POSITION_TOP)
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UISegmentedControl {
    func defaultConfiguration(font: UIFont = UIFont.systemFont(ofSize: 16), color: UIColor = UIColor()) {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }

    func selectedConfiguration(font: UIFont = UIFont.boldSystemFont(ofSize: 16), color: UIColor = UIColor()) {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont(name: "Inter-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "Inter-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}

    func bold(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func underlined(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
