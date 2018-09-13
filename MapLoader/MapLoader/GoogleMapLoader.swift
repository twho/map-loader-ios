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

open class GoogleMapLoader: MapLoader {
    // MARK: - Variables accessible by other class
    override open var isLocationButtonShown: Bool {
        didSet {
            showLocateButton(isLocationButtonShown)
        }
    }
    
    /**
     The GoogleMapView used by MapLoader.
     */
    private var gMapView: GMSMapView!
    
    // Init
    public override init() {
        super.init()
        
        // Set initial value
        LOG_TAG = "[GoogleMapLoader] "
        defaultZoom = 14.0
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
    }
    
    /**
     Deserializing the object.
     */
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func addAnnotations(_ annotations: [MLAnnotation]) {
        DispatchQueue.main.async {
            // Let cluster manager manage clusters after loading all annotations
            self.clusterMgr.add(annotations)
            self.clusterMgr.reload(mapView: self.gMapView)
        }
    }
    
    public override func removeAllAnnotations() {
        clusterMgr.removeAll()
        
        // Check if mapView is nil
        if let mapView = gMapView {
            mapView.clear()
        }
    }
    
    public override func removeAnnotation(_ annotation: MLAnnotation) {
        self.clusterMgr.remove(annotation)
        if let marker = (annotation as? MLMarker) {
            marker.marker.map = nil
        }
    }
    
    /**
     Set Google API key
     */
    public static func setAPIKey(_ key: String) {
        GMSServices.provideAPIKey(key)
    }
    
    open override func getMapView() -> Any {
        return self.gMapView
    }
    
    public override func layoutMapView() {
        if let mapContainer = mapContainer {
            gMapView.frame = mapContainer.frame
        }
    }
    
    public override func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
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
    
    public override func showLocateButton(_ show: Bool) {
        gMapView.settings.myLocationButton = show
    }
    
    public override func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation, let mapView = gMapView else { return }
        let zoomLevel = zoom ? defaultZoom*1.5 : defaultZoom
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: Float(zoomLevel))
        mapView.animate(to: camera)
    }
    
    public override func generateClusteringView(annotation: Any) -> UIView? {
        guard let _ = annotation as? ClusterAnnotation, let annotation = annotation as? MKAnnotation else { return nil }
        // Decide if annotation appears to be as an annotation or cluster
        let style = ClusterAnnotationStyle.color(clusterColor, radius: 25)
        return BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: nil, style: style, borderColor: .white)
    }
    
    public override func refreshMap(completion: ((Bool) -> Void)? = nil) {
        if let completion = completion {
            clusterMgr.reload(mapView: self.gMapView, completion: completion)
        } else {
            clusterMgr.reload(mapView: self.gMapView)
        }
    }
    
    internal override func cleanUpMapMemory() {
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
extension GoogleMapLoader {
    // Handle location updates.
    public override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
