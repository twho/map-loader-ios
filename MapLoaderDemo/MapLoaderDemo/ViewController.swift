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
     Sample geo points.
     */
    let geoCenter = CLLocationCoordinate2D(latitude: 42.35619599, longitude: -71.05957196)
    let geoPoint1 = CLLocationCoordinate2D(latitude: 42.35273449, longitude: -71.06350985)
    let geoPoint2 = CLLocationCoordinate2D(latitude: 42.35307061, longitude: -71.05916667)
    let geoPoint3 = CLLocationCoordinate2D(latitude: 42.35130579, longitude: -71.05957196)
    let geoPoint4 = CLLocationCoordinate2D(latitude: 42.36098194, longitude: -71.05897865)
    let geoPoint5 = CLLocationCoordinate2D(latitude: 42.36326194, longitude: -71.05080375)
    let geoPoint6 = CLLocationCoordinate2D(latitude: 42.34798343, longitude: -71.05960375)
    /**
     Sample annotation images.
     */
    let annotImg1 = StyledAnnotationView(annotImg: .gas, background: .square)
    let annotImg2 = StyledAnnotationView(annotImg: .police, background: .heart)
    let annotImg3 = StyledAnnotationView(annotImg: .hazard, color: UIColor.lightGray, background: .bubble, bgColor: UIColor.blue)
    let annotImg4 = StyledAnnotationView(annotImg: .charging, background: .flag, bgColor: UIColor.orange)
    let annotImg5 = StyledAnnotationView(annotImg: .personal, background: .circle, bgColor: UIColor.purple)
    let annotImg6 = StyledAnnotationView(annotImg: .hazard, background: .square, bgColor: UIColor.red)
    let annotImg7 = StyledAnnotationView(annotImg: .construction, color: UIColor.black, background: .flag, bgColor: UIColor.yellow)
    
    // MARK: - In-class variables
    private var mapLoader: MapLoader!
    private var googleMapLoader: GoogleMapLoader!
    private var lastLocation: CLLocationCoordinate2D?
    private var useGoogle: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapLoader = GoogleMapLoader()
        refreshMap()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        useGoogle ? googleMapLoader.setupMapView(mapContainer: self.view, viewAboveMap: nil, delegate: self) : mapLoader.setupMapView(mapContainer: self.view, viewAboveMap: nil, delegate: self)
        if useGoogle {
            googleMapLoader.isLocationButtonShown = true
        } else {
            mapLoader.isLocationButtonShown = true
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set mapView fill the screen and assign the delegate
        useGoogle ? googleMapLoader.layoutMapView() : mapLoader.layoutMapView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func didSwitchMap(_ sender: UISegmentedControl) {
        useGoogle ? googleMapLoader.cleanUpMapMemory() : mapLoader.cleanUp()
        useGoogle = sender.selectedSegmentIndex == 0
        switch sender.selectedSegmentIndex {
        case 0:
            googleMapLoader = GoogleMapLoader()
        case 1:
            mapLoader = MapLoader()
        default:
            googleMapLoader = GoogleMapLoader()
        }
        self.viewWillAppear(true)
        refreshMap()
    }
    private func refreshMap() {
        useGoogle ? googleMapLoader.removeAllAnnotations() : mapLoader.removeAllAnnotations()
        
        // Sample location and image set
        let imgSet = [annotImg1, annotImg2, annotImg3, annotImg4, annotImg5, annotImg6, annotImg7]
        let locSet = [geoCenter, geoPoint1, geoPoint2, geoPoint3, geoPoint4, geoPoint5, geoPoint6]
        DispatchQueue.main.async {
            if self.useGoogle {
                var markers: [MLMarker] = []
                for i in 0..<locSet.count {
                    let annotation = MLMarker(coordinate: locSet[i], annotView: imgSet[i], data: nil)
                    markers.append(annotation)
                }
                self.googleMapLoader.addAnnotations(markers)
            } else {
                var annotations: [MLAnnotation] = []
                for i in 0..<locSet.count {
                    let annotation = MLAnnotation(coordinate: locSet[i], annotView: imgSet[i], data: nil)
                    annotations.append(annotation)
                }
                self.mapLoader.addAnnotations(annotations)
            }
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
        googleMapLoader.centerCurrentLocation(zoom: true)
        return true
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        googleMapLoader.refreshMap()
    }
}
