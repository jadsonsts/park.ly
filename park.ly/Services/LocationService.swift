//
//  LocationService.swift
//  park.ly
//
//  Created by Jadson on 19/05/22.
//

import Foundation
import CoreLocation

protocol CustomUserLocDelegate {
    func userLocationUpdated(location: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instante = LocationService()
    
    var customUserLocDelegate: CustomUserLocDelegate?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location?.coordinate
        if customUserLocDelegate != nil {
            customUserLocDelegate?.userLocationUpdated(location: locations.first!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
