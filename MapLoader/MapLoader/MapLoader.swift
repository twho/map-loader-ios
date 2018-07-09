//
//  MapHandler.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/4/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import CoreLocation

open class MapLoader: NSObject, MapLoaderFunction, MapClusterFunction {
    
    var LOG_TAG = "[MapHandler] "
    
    // In-class variables
    private var didDefaultZoomIn = false
    private let implErrMsg = "\(#function) must be implemented by children class"
    private let implByDfltMapMsg = "\(#function) should be implemented by DefaultMapLoader, but is not available for Google map system"
    
    // Variables accessible by other class
    public var clusterColor = UIColor(red:0.23, green:0.64, blue:0.39, alpha:1.0) // Green color
    
    // Variables accessible by subclass
    internal var mapContainer: UIView!
    internal var locationMgr: CLLocationManager?
    internal var mostRecentLocation: CLLocation?
    internal var defaultLocation = CLLocationCoordinate2D(latitude: 42.301570, longitude: -71.479392)
    
    public override init() {
        super.init()
        
        setupLocationMgr()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Set default location which is used when the location manager cannot get current location
     
     - Parameter latitude: latitude of default location
     - Parameter longitude: longitude of default location
     */
    public func setDefaultLocation(latitude: Double, longitude: Double){
        self.defaultLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func setDefaultZoom(_ value: Float) {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    // Should be put in viewDidLayoutSubviews()
    public func layoutMapView() {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func getMapView() -> Any {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func centerCurrentLocation(zoom: Bool) {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func addAnnotations(annotations: [MLAnnotation]) {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func removeAllAnnotations() {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func removeAnnotation(annotation: MLAnnotation) {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func refreshMap() {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func cleanUpMapMemory() {
        fatalError(LOG_TAG + implErrMsg)
    }
    
    public func onClickLocate() {
        centerCurrentLocation(zoom: false)
    }
    
    public func cleanUp() {
        cleanUpMapMemory()
        
        locationMgr?.stopUpdatingLocation()
        locationMgr?.delegate = nil
        locationMgr = nil
    }
    
    public func setupLocationMgr() {
        self.locationMgr = CLLocationManager()
        if let manager = self.locationMgr {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.delegate = self
            manager.startUpdatingLocation()
        }
    }
    
    // Set minimum cluster count, only available for default map
    public func setMinCountForClustering(minCount: Int) {
        fatalError(LOG_TAG + implByDfltMapMsg)
    }
    
    // Generate cluster views, only available for default map
    public func generateClusteringView(annotation: Any) -> UIView? {
        fatalError(LOG_TAG + implByDfltMapMsg)
    }
    
    public func setClusterColor(color: UIColor) {
        self.clusterColor = color
    }
}

protocol MapLoaderFunction {
    func setDefaultZoom(_ value: Float)
    func layoutMapView()
    func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?)
    func centerCurrentLocation(zoom: Bool)
    func addAnnotations(annotations: [MLAnnotation])
    func removeAllAnnotations()
    func removeAnnotation(annotation: MLAnnotation)
    func refreshMap()
    func cleanUpMapMemory()
}

protocol MapClusterFunction {
    func setMinCountForClustering(minCount: Int)
    func generateClusteringView(annotation: Any) -> UIView?
    func setClusterColor(color: UIColor)
}

extension MapLoader: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            mostRecentLocation = lastLocation
        }
        
        // Only center user location once when user open up the map
        if !didDefaultZoomIn {
            centerCurrentLocation(zoom: false)
            didDefaultZoomIn = true
        }
    }
}
