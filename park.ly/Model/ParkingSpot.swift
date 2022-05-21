//
//  ParkingSpot.swift
//  park.ly
//
//  Created by Jadson on 21/05/22.
//

import UIKit
import MapKit

class ParkingSpot: NSObject, MKAnnotation {
    var title: String? = "Parked Here"
    var subtitle: String? = "Tap for direction"
    var coordinate: CLLocationCoordinate2D
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
