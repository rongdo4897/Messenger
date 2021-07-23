//
//  LocationMessage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/07/2021.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
