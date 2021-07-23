//
//  MapViewController.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/07/2021.
//

import UIKit
import MapKit
import CoreLocation

//MARK: - Outlet, Override
class MapViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let distanceSpan: CLLocationDistance = 300
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        customizeComponents()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action - Obj
extension MapViewController {
    
}

//MARK: - Các hàm khởi tạo, Setup
extension MapViewController {
    private func initComponents() {
        initMapView()
        initTopView()
    }
    
    private func initMapView() {
        mapView.showsUserLocation = true
        
        if location != nil {
            let mapCoordinates = MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
            mapView.setRegion(mapCoordinates, animated: true)
            
            let annotation = MapAnnotation(title: "I'm here".localized(), coordinate: location!.coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func initTopView() {
        self.lblTitle.text = "Map".localized()
    }
}

//MARK: - Customize
extension MapViewController {
    private func customizeComponents() {
        
    }
}

//MARK: - Các hàm chức năng
extension MapViewController {
    
}
