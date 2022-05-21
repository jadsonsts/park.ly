//
//  ViewController.swift
//  park.ly
//
//  Created by Jadson on 19/05/22.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var parkButton: RoundButton!
    @IBOutlet weak var directionButton: RoundButton!
    
    var parkedCarAnnotation: ParkingSpot?
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationAuthStatus()
        mapView.delegate = self
        directionButton.isEnabled = false
        setupLongPress()
    }

    @IBAction func resetMapCenter(sender: RoundButton) {
        guard let coordinate = LocationService.instante.currentLocation else {return}
        centerMapUserLocation(coordinate: coordinate)
    }
    
    @IBAction func parkBtnTapped(sender: RoundButton) {
        //removing annotations from the map before checking
        mapView.removeAnnotations(mapView.annotations)
        removeOverlays()
        
        guard let coordinate = LocationService.instante.currentLocation else { return }
        //check if there is no annotation (the pin), add it and change the button, if there is an annotation, remove it
        //before: mapView.annotations.count == 1
        if parkedCarAnnotation == nil {
            setupAnnotation(coordinate: coordinate)
            parkButton.setImage(UIImage(named: "foundCar"), for: .normal)
            directionButton.isEnabled = true
        } else {
            parkButton.setImage(UIImage(named: "parkCar"), for: .normal)
            parkedCarAnnotation = nil
            directionButton.isEnabled = false
            centerMapUserLocation(coordinate: coordinate)
        }
    }
    
    @IBAction func getDirectionsTapped(sender: RoundButton) {
        guard let userCoordinates = LocationService.instante.currentLocation, let parkedCar = parkedCarAnnotation else {return}
        getDirectionsToCar(userCoordinates: userCoordinates, parkedCar: parkedCar.coordinate)
    }
    
}

//MARK: - Request User location and set the annotation
extension ViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
            LocationService.instante.customUserLocDelegate = self
        } else {
            LocationService.instante.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapUserLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setupAnnotation(coordinate: CLLocationCoordinate2D) {
        parkedCarAnnotation = ParkingSpot(coordinate: coordinate)
        mapView.addAnnotation(parkedCarAnnotation!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingSpot {
            let id = "pin"
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesDrop = true
            view.pinTintColor = .systemCyan
            view.calloutOffset = CGPoint(x: -8, y: -3)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        return nil
    }
    
    //using the annotation pin to get the directions
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let location = LocationService.instante.currentLocation, let parkedCar = parkedCarAnnotation else { return }
        getDirectionsToCar(userCoordinates: location, parkedCar: parkedCar.coordinate)
        view.setSelected(false, animated: true)
    }
}
//MARK: - User Location Delegate
extension ViewController: CustomUserLocDelegate {
    func userLocationUpdated(location: CLLocation) {
        centerMapUserLocation(coordinate: location.coordinate)
    }
    
    
}
//MARK: - Handle the long press location
extension ViewController {
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPress.minimumPressDuration = 0.25 //1sec seems a bit long for a simulator
        self.mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        removeOverlays()
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            setupAnnotation(coordinate: coordinate)
            
            directionButton.isEnabled = true
            parkButton.setImage(UIImage(named: "foundCar"), for: .normal)
        }
    }
}
//MARK: - direction from user to the car
extension ViewController {
    func getDirectionsToCar(userCoordinates: CLLocationCoordinate2D, parkedCar: CLLocationCoordinate2D) {
        
        removeOverlays()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: parkedCar))
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        
        //unowned is for memory leak, not using weak self because it cannot be nil. if it can, weak self works
        direction.calculate { [unowned self] response, error in
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
            
            //same: to have the distance
            print (route.distance)
            //step by step instructions
            for step in route.steps {
                print(step.distance)
                print(step.instructions)
            }
            
            /* if showing the distance between the car and the user: 👇🏽
            let userLatLong = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
            let parkedCardLatLong = CLLocation(latitude: parkedCar.latitude, longitude: parkedCar.longitude)
            let distance = userLatLong.distance(from: parkedCardLatLong) / 1000
            print("distance in km: \(distance)") (atribute this to a label or something)*/
        }
    }
    
    // calling a renderer func to help the app to use the code
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let directionsRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        //setting the UI for the line
        directionsRenderer.strokeColor = .systemPink
        directionsRenderer.lineWidth = 5
        directionsRenderer.alpha = 0.7 //transparency
        
        return directionsRenderer
    }
    
    func removeOverlays() {
        self.mapView.overlays.forEach { self.mapView.removeOverlay($0)}
    }
}
