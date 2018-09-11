//
//  MapLoader.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/4/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

open class MapLoader: NSObject, MapLoaderFunction, MapClusterFunction, MapLoaderVariables {
    var LOG_TAG = "[MapHandler] "
    
    // MARK: - Variables accessible by other class
    open var defaultZoom: Double = 0.03
    open var clusterColor = UIColor(red:0.00, green:0.70, blue:0.36, alpha:1.0) // Green color
    open var isLocationButtonShown: Bool = false {
        didSet {
            showLocateButton(isLocationButtonShown)
        }
    }
    // MARK: - In-class variables
    /**
     Stored expanded annotation.
     */
    private var currentExpandAnnotation: MLAnnotation?
    /**
     The MapView used by MapLoader.
     */
    private var mapView: MKMapView!

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
    
    /**
     Set default location which is used when the location manager cannot get current location.
     
     - Parameter latitude: latitude of default location
     - Parameter longitude: longitude of default location
     */
    public func setDefaultLocation(latitude: Double, longitude: Double){
        self.defaultLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func setDefaultZoom(_ value: Double) {
        defaultZoom = value
    }
    
    public func layoutMapView() {
        if let mapContainer = mapContainer {
            mapView.frame = mapContainer.frame
        }
    }
    
    public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
        mapView = MKMapView()
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        
        if let delegate = delegate as? MKMapViewDelegate {
            mapView.delegate = delegate
        }
        
        if let viewAboveMap = viewAboveMap {
            mapContainer.insertSubview(mapView, belowSubview: viewAboveMap)
        } else {
            mapContainer.insertSubview(mapView, at: 0)
        }
        self.mapContainer = mapContainer
    }
    
    public func showLocateButton(_ show: Bool) {
        
    }
    
    open func getMapView() -> Any {
        return self.mapView
    }
    
    public func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation, let mapView = mapView else { return }
        
        var region: MKCoordinateRegion
        if zoom {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: defaultZoom/5, longitudeDelta: defaultZoom/5))
        } else {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom))
        }
        mapView.setRegion(region, animated: true)
    }
    
    public func addAnnotations(_ annotations: [MLAnnotation]) {
        DispatchQueue.main.async {
            // Let cluster manager manage clusters after loading all annotations
            self.clusterMgr.add(annotations)
            self.clusterMgr.reload(mapView: self.mapView)
        }
    }
    
    public func removeAnnotation(_ annotation: MLAnnotation) {
        self.clusterMgr.remove(annotation)
        
        // Check if mapView is nil
        guard let mapView = mapView else { return }
        mapView.removeAnnotation(annotation)
    }
    
    public func removeAllAnnotations() {
        clusterMgr.removeAll()
        
        // Check if mapView is nil
        guard let mapView = mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
    }
    
    public func refreshMap(completion: ((Bool) -> Void)? = nil) {
        if let completion = completion {
            clusterMgr.reload(mapView: mapView, completion: completion)
        } else {
            clusterMgr.reload(mapView: mapView)
        }
    }
    
    public func setMaxZoomLevel(_ maxZoom: Double) {
        clusterMgr.maxZoomLevel = maxZoom
    }
    
    public func getCurrentZoomLevel() -> Double {
        return clusterMgr.zoomLevel
    }
    
    internal func cleanUpMapMemory() {
        if nil != mapView {
            self.mapView.removeAnnotations(mapView.annotations)
            self.mapView.delegate = nil
            self.mapView.showsUserLocation = false
            self.mapView.removeFromSuperview()
            self.mapView = nil
        }
        
        clusterMgr.removeAll()
    }
    
    /**
     Clean up memory usage.
     */
    public func cleanUp() {
        cleanUpMapMemory()
        
        locationMgr.stopUpdatingLocation()
        locationMgr.delegate = nil
    }
    
    public func setMinCountForClustering(_ minCount: Int) {
        clusterMgr.minCountForClustering = minCount
    }
    
    public func generateClusteringView(annotation: Any) -> UIView? {
        // Decide if annotation appears to be as an annotation or cluster
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "cluster"
            let style = ClusterAnnotationStyle.color(clusterColor, radius: 25)
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? BorderedClusterAnnotationView {
                view.annotation = annotation
                view.style = style
                view.configure()
            } else {
                view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, style: style, borderColor: .white)
            }
            return view
        } else if let annotation = annotation as? MLAnnotation {
            // Check if ExpandAnnotationView is available
            let identifier = "marker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view {
                view.annotation = annotation
            } else {
                if #available(iOS 11.0, *), annotation.useDefaultView {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
            }
            if #available(iOS 11.0, *), annotation.useDefaultView {
                (view as! MKMarkerAnnotationView).glyphImage = annotation.annotImg
                (view as! MKMarkerAnnotationView).markerTintColor = annotation.annotBgColor
            } else {
                view?.image = annotation.annotImg
            }
            return view
        }
        return nil
    }
    
    public func setClusterColor(color: UIColor) {
        self.clusterColor = color
    }
}

// MARK: - CLLocationManagerDelegate
extension MapLoader: CLLocationManagerDelegate {
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

// MARK: - MapLoader built-in animations
extension MapLoader {
    /**
     Animations built-in in MapLoader.
     
     - fadeIn:   fade in the target view
     - zoomIn:   enlarge the target view
     - zoomOut:  reset the target view to original size
     - bounceIn: show target view with bounce animation
     - pop:      zoom in the target view then zoom it out immediately
     */
    public enum AnnotationAnimation {
        case fadeIn
        case zoomIn
        case zoomOut
        case bounceIn
        case pop
    }
    
    /**
     Perform the animation to multiple annotations.
     
     - Parameter annotations: the target annotation view to perform animation
     - Parameter animation:   the animation type provided by MapLoader
     - Parameter duration:    the time duration of the animation
     - Parameter completion:  the task to do after the animation is finished
     */
    public func animate(annotations: [UIView], animation: AnnotationAnimation, duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        switch animation {
        case .fadeIn:
            annotations.forEach { $0.alpha = 0 }
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                annotations.forEach { $0.alpha = 1 }
            }, completion: completion)
        case .zoomIn:
            annotations.forEach { $0.transform = CGAffineTransform.identity }
            UIView.animate(withDuration: duration, animations: {
                annotations.forEach { $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }
            }, completion: completion)
        case .zoomOut:
            annotations.forEach { $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }
            UIView.animate(withDuration: duration, animations: {
                annotations.forEach { $0.transform = CGAffineTransform.identity }
            }, completion: completion)
        case .bounceIn:
            annotations.forEach {
                let offset = CGPoint(x: 0, y: $0.frame.height - $0.frame.minY)
                $0.transform = CGAffineTransform(translationX: offset.x + 0, y: offset.y + 0)
            }
            
            UIView.animate(
                withDuration: duration, delay: 0, usingSpringWithDamping: 0.58, initialSpringVelocity: 3,
                options: .curveEaseOut, animations: {
                    annotations.forEach {
                        $0.transform = .identity
                        $0.alpha = 1
                    }
            }, completion: completion)
        case .pop:
            for annotation in annotations {
                UIView.animate(withDuration: duration/2, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 3, animations: {
                    annotation.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: { finished in
                    UIView.animate(withDuration: duration/2, animations: {
                        annotation.transform = CGAffineTransform.identity
                    }, completion: completion)
                })
            }
        }
    }
    
    /**
     Perform the animation to single annotation.
     
     - Parameter annotations: the target annotation view to perform animation
     - Parameter animation:   the animation type provided by MapLoader
     - Parameter duration:    the time duration of the animation
     - Parameter completion:  the task to do after the animation is finished
     */
    public func animate(annotation: UIView, animation: AnnotationAnimation, duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil) {
        animate(annotations: [annotation], animation: animation, duration: duration, completion: completion)
    }
}
