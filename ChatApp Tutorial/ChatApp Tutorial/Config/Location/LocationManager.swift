//
//  LocationManager.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/07/2021.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let share = LocationManager()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    private override init() {
        super.init()
        requestLocationAccess()
    }
}

extension LocationManager {
    // yêu cầu Quyền truy cập vị trí
    private func requestLocationAccess() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    // Bắt đầu cập nhật
    func startUpdating() {
        locationManager!.startUpdatingLocation()
    }
    
    // Dừng cập nhật
    func stopUpdating() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
}

//MARK: - Delegate
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Lỗi khi lấy vị trí")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
}
