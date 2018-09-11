//
//  GoogleMapLoader.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 9/5/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import GoogleMaps
import CustomMapAnnotation
import MapKit

open class GoogleMapLoader: NSObject, MapLoaderVariables, MapLoaderFunction, MapClusterFunction {
    let LOG_TAG = "[GoogleMapLoader] "
    
    // MARK: - Variables accessible by other class
    open var defaultZoom: Double = 14.0
    open var clusterColor = UIColor(red:0.00, green:0.70, blue:0.36, alpha:1.0) // Green color
    open var isLocationButtonShown: Bool = false {
        didSet {
            showLocateButton(isLocationButtonShown)
        }
    }
    
    // MARK: - Variables accessible by subclass
    internal lazy var locationMgr: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    internal var clusterMgr = ClusterManager()
    internal var mostRecentLocation: CLLocation?
    internal var mapContainer: UIView?
    internal var didDefaultZoomIn = false
    internal var defaultLocation = CLLocationCoordinate2D(latitude: 42.301570, longitude: -71.479392)
    
    /**
     The GoogleMapView used by MapLoader.
     */
    private var gMapView: GMSMapView!
    
    // Init
    public override init() {
        super.init()
        locationMgr.startUpdatingLocation()
    }
    
    /**
     Deserializing the object.
     */
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setDefaultZoom(_ value: Double) {
        self.defaultZoom = value
    }
    
    public func addAnnotations(_ annotations: [MLAnnotation]) {
        DispatchQueue.main.async {
            // Let cluster manager manage clusters after loading all annotations
            self.clusterMgr.add(annotations)
            self.clusterMgr.reload(mapView: self.gMapView)
        }
    }
    
    public func removeAllAnnotations() {
        clusterMgr.removeAll()
        
        // Check if mapView is nil
        if let mapView = gMapView {
            mapView.clear()
        }
    }
    
    public func removeAnnotation(_ annotation: MLAnnotation) {
        self.clusterMgr.remove(annotation)
        if let marker = (annotation as? MLMarker) {
            marker.marker.map = nil
        }
    }
    
    public func setMaxZoomLevel(_ maxZoom: Double) {
        clusterMgr.maxZoomLevel = maxZoom
    }
    
    public func getCurrentZoomLevel() -> Double {
        return clusterMgr.zoomLevel
    }
    
    public func setMinCountForClustering(_ minCount: Int) {
        clusterMgr.minCountForClustering = minCount
    }
    
    public func setClusterColor(color: UIColor) {
        self.clusterColor = color
    }
    
    /**
     Set Google API key
     */
    public static func setAPIKey(key: String) {
        GMSServices.provideAPIKey(key)
    }
    
    open func getMapView() -> Any {
        return self.gMapView
    }
    
    public func layoutMapView() {
        if let mapContainer = mapContainer {
            gMapView.frame = mapContainer.frame
        }
    }
    
    public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
        var camera = GMSCameraPosition.camera(withLatitude: defaultLocation.latitude,
                                              longitude: defaultLocation.longitude,
                                              zoom: Float(defaultZoom))
        if let location = self.mostRecentLocation {
            camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: Float(defaultZoom))
        }
        gMapView = GMSMapView.map(withFrame: mapContainer.frame, camera: camera)
        gMapView.accessibilityElementsHidden = false
        gMapView.settings.compassButton = true
        gMapView.settings.zoomGestures = true
        gMapView.isMyLocationEnabled = true
        if let delegate = delegate as? GMSMapViewDelegate {
            gMapView.delegate = delegate
        }
        if let viewAboveMap = viewAboveMap {
            mapContainer.insertSubview(gMapView, belowSubview: viewAboveMap)
        } else {
            mapContainer.insertSubview(gMapView, at: 0)
        }
        self.mapContainer = mapContainer
    }
    
    public func showLocateButton(_ show: Bool) {
        gMapView.settings.myLocationButton = show
    }
    
    public func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation, let mapView = gMapView else { return }
        let zoomLevel = zoom ? defaultZoom*1.5 : defaultZoom
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: Float(zoomLevel))
        mapView.animate(to: camera)
    }
    
    public func generateClusteringView(annotation: Any) -> UIView? {
        guard let _ = annotation as? ClusterAnnotation, let annotation = annotation as? MKAnnotation else { return nil }
        // Decide if annotation appears to be as an annotation or cluster
        let style = ClusterAnnotationStyle.color(clusterColor, radius: 25)
        return BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: nil, style: style, borderColor: .white)
    }
    
    public func refreshMap(completion: ((Bool) -> Void)? = nil) {
        if let completion = completion {
            clusterMgr.reload(mapView: self.gMapView, completion: completion)
        } else {
            clusterMgr.reload(mapView: self.gMapView)
        }
    }
    
    internal func cleanUpMapMemory() {
        if nil != gMapView {
            self.gMapView.isMyLocationEnabled = false
            self.gMapView.delegate = nil
            self.gMapView.removeFromSuperview()
            self.gMapView = nil
        }
        clusterMgr.removeAll()
    }
}

// MARK: - CLLocationManagerDelegate
extension GoogleMapLoader: CLLocationManagerDelegate {
    // Handle location updates.
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
