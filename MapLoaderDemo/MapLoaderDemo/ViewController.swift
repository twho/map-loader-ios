//
//  ViewController.swift
//  MapLoaderDemo
//
//  Created by Ho, Tsung Wei on 9/5/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import CustomMapAnnotation

class ViewController: UIViewController {
    /**
     Sample annotation images.
     */
    let annotImg1 = StyledAnnotationView(annotImg: .gas, background: .square)
    let annotImg2 = StyledAnnotationView(annotImg: .police, background: .heart)
    let annotImg3 = StyledAnnotationView(annotImg: .hazard, color: UIColor.white, background: .bubble, bgColor: UIColor.blue)
    let annotImg4 = StyledAnnotationView(annotImg: .charging, background: .flag, bgColor: UIColor.orange)
    let annotImg5 = StyledAnnotationView(annotImg: .personal, background: .circle, bgColor: UIColor.purple)
    let annotImg6 = StyledAnnotationView(annotImg: .hazard, background: .square, bgColor: UIColor.red)
    let annotImg7 = StyledAnnotationView(annotImg: .construction, color: UIColor.black, background: .flag, bgColor: UIColor.yellow)
    
    // MARK: - In-class variables
    private var mapLoader: MapLoader!
    private var lastLocation: CLLocation?
    private lazy var locationMgr: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMgr.startUpdatingLocation()
        mapLoader = GoogleMapLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapLoader.setupMapView(mapContainer: self.view, viewAboveMap: nil, delegate: self)
        mapLoader.isLocationButtonShown = true
        refreshMap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set mapView fill the screen and assign the delegate
        mapLoader.layoutMapView()
    }
    
    @IBAction func didSwitchMap(_ sender: UISegmentedControl) {
        mapLoader.cleanUp()
        switch sender.selectedSegmentIndex {
        case 0:
            mapLoader = GoogleMapLoader()
        case 1:
            mapLoader = MapLoader()
        default:
            mapLoader = GoogleMapLoader()
        }
        self.viewWillAppear(true)
    }
    
    private func refreshMap() {
        mapLoader.removeAllAnnotations()
        // Sample location and image set
        let imgSet = [annotImg1, annotImg2, annotImg3, annotImg4, annotImg5, annotImg6, annotImg7]
        var locSet = getMockLocationsFor(coordinate: mapLoader.defaultLocation, itemCount: 15)
        if let lastLocation = self.lastLocation {
            locSet = getMockLocationsFor(coordinate: CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude), itemCount: 15)
        }
        DispatchQueue.main.async {
            var annotations: [MLAnnotation] = []
            for i in 0..<locSet.count {
                var annotation = MLAnnotation(coordinate: locSet[i], annotView: imgSet[i%7], data: nil)
                if let _ = (self.mapLoader as? GoogleMapLoader) {
                    annotation = MLMarker(coordinate: locSet[i], annotView: imgSet[i%7], data: nil)
                }
                annotations.append(annotation)
            }
            self.mapLoader.addAnnotations(annotations)
        }
    }
    
    /**
     Generate random location around user's location.
     ref: inorganik@Github
     
     - Parameter location:  User's current location.
     - Parameter itemCount: The number of fake location coordinates to be generated.
     
     - Returns an array of geo location
     */
    func getMockLocationsFor(coordinate: CLLocationCoordinate2D, itemCount: Int) -> [CLLocationCoordinate2D] {
        let baseLatitude = round((coordinate.latitude - 0.007) * 10000) / 10000
        let baseLongitude = round((coordinate.longitude - 0.008) * 10000) / 10000
        
        var items = [CLLocationCoordinate2D]()
        for _ in 0..<itemCount {
            let location = CLLocationCoordinate2D(latitude: baseLatitude + Double(arc4random_uniform(140)) * 0.0001, longitude: baseLongitude + Double(arc4random_uniform(140)) * 0.0001)
            items.append(location)
        }
        return items
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        let distance = self.lastLocation?.distance(from: lastLocation)
        // Refresh the map markers only if the center is changed to more than 30 meters away from its origin
        if nil == distance || !distance!.isLess(than: 30.0) {
            self.lastLocation = lastLocation
            refreshMap()
        }
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return mapLoader.generateClusteringView(annotation: annotation) as? MKAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard nil == (view.annotation as? ClusterAnnotation), let _ = (view.annotation as? MLAnnotation) else { return }
        mapLoader.animate(annotation: view, animation: .zoomIn, duration: 0.25)
        if let annotation = (view.annotation as? MLAnnotation) {
            annotation.isExpanded = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapLoader.animate(annotation: view, animation: .zoomOut, duration: 0.25)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapLoader.refreshMap()
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        mapLoader.animate(annotations: views, animation: .fadeIn)
    }
}
// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapLoader.centerCurrentLocation(zoom: true)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let view = marker.iconView else { return false }
        mapLoader.animate(annotation: view, animation: .zoomIn, duration: 0.15)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapLoader.refreshMap()
    }
}
