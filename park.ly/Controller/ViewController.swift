//
//  ViewController.swift
//  park.ly
//
//  Created by Jadson on 19/05/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationAuthStatus()
    }


}

extension ViewController {
    func checkLocationAuthStatus() {
        if manager.authorizationStatus == .authorizedWhenInUse {
            print("YAY we can see you")
        } else {
            LocationService.instante.locationManager.requestLocation()
        }
    }
}

