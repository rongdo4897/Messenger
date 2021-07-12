//
//  DateExtension.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 17/06/2021.
//

import Foundation

enum DateType: String {
    case day
    case month
    case year
}

extension Date {
    func longDate(type: DateType) -> String {
        let dateFormater = DateFormatter()
        if type == .day {
            dateFormater.dateFormat = "dd"
        } else if type == .month {
            dateFormater.dateFormat = "MMM"
        } else {
            dateFormater.dateFormat = "yyyy"
        }
        return dateFormater.string(from: self)
    }
    
    func time() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        return dateFormater.string(from: self)
    }
}
