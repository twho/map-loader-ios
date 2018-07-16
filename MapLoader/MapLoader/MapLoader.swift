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

// MARK: MapLoaderFunction protocol
/**
 The protocol that defines the functions that a MapLoader should have and implement.
 */
protocol MapLoaderFunction {
    /**
     Set default zoom value.
     
     - Parameter value: the default zoom in float value
     */
    func setDefaultZoom(_ value: Float)
    
    /**
     Set map frame parameters and layout map. This function is Usually used in viewDidLayoutSubviews().
     */
    func layoutMapView()
    
    /**
     Setup MapView and insert it to container.
     
     - Parameter mapContainer: the view to insert MapView to
     - Parameter viewAbove:    the view above the map, set nil if there is nothing above the MapView
     - Parameter delegate:     the MapView delegate
     */
    func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?)
    
    /**
     Get MapView used by MapLoader.
     
     Returns any types of MapView
     */
    func getMapView() -> Any
    
    /**
     Center current user location.
     
     - Paramter zoom: boolean to determine if zoom in MapView
     */
    func centerCurrentLocation(zoom: Bool)
    
    /**
     Add annotations to MapView.
     
     - Parameter annotations: an array of MLAnnotations to be added to MapView
     */
    func addAnnotations(annotations: [MLAnnotation])
    
    /**
     Remove all annotations.
     */
    func removeAllAnnotations()
    
    /**
     Remove certain annotation from the MapView.
     
     - Parameter annotation: the annotation to be removed from the map
     */
    func removeAnnotation(annotation: MLAnnotation)
    
    /**
     Refresh annotations on the MapView.
     
     - Paramter completion: the task to perform after map finished refresing. Set nil if there is no task
     */
    func refreshMap(completion: ((Bool)->Void)?)
    
    /**
     Clean up memory used by the MapView and mapLoader.
     */
    func cleanUpMapMemory()
}

// MARK: MapClusterFunction protocol
/**
 The protocol defines the functions that a MapLoader using annotation clustering should implement.
 */
protocol MapClusterFunction {
    /**
     Set minimum cluster count.
     
     - Parameter minCount: the minimum count for clustering annotations
     */
    func setMinCountForClustering(minCount: Int)
    
    /**
     Generate cluster views, only available for default map.
     
     - Parameter annotation: the annotation to be based on for generating view
     
     Returns an UIView that represents the view generated given annotaion
     */
    func generateClusteringView(annotation: Any) -> UIView?
    
    /**
     Set cluster color.
     
     - Parameter color: the color to be set to clusters
     */
    func setClusterColor(color: UIColor)
}

open class MapLoader: NSObject, MapLoaderFunction, MapClusterFunction {
    
    var LOG_TAG = "[MapHandler] "
    
    // MARK: Variables accessible by other class
    open var defaultZoom = 0.03
    open var clusterColor = UIColor(red:0.00, green:0.70, blue:0.36, alpha:1.0) // Green color
    
    // MARK: In-class variables
    /**
     Flag that indicates if the map is zoom in already.
     */
    private var didDefaultZoomIn = false
    
    /**
     The MapView used by MapLoader.
     */
    private var mapView: MKMapView!
    
    /**
     The cluster manager for clustering annotations.
     */
    private let clusterMgr = ClusterManager()

    // MARK: Variables accessible by subclass
    /**
     The UIView container to contain the map.
     */
    internal var mapContainer: UIView!
    
    /**
     The LocationManager used by MapLoader.
     */
    internal var locationMgr: CLLocationManager?
    
    /**
     The most recent location updated by LocationManager.
     */
    internal var mostRecentLocation: CLLocation?
    
    /**
     The default location to show if MapLoader cannot retrieve location from LocationManager.
     */
    internal var defaultLocation = CLLocationCoordinate2D(latitude: 42.301570, longitude: -71.479392)
    
    // Init
    public override init() {
        super.init()
        
        setupLocationMgr()
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
    
    public func setDefaultZoom(_ value: Float) {
        defaultZoom = Double(value)
    }
    
    public func layoutMapView() {
        mapView.frame = mapContainer.frame
    }
    
    public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
        self.mapContainer = mapContainer
        mapView = MKMapView()
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        
        if let delegate = delegate as? MKMapViewDelegate {
            mapView.delegate = delegate
        }
        
        if let viewAboveMap = viewAboveMap {
            self.mapContainer.insertSubview(mapView, belowSubview: viewAboveMap)
        } else {
            self.mapContainer.insertSubview(mapView, at: 0)
        }
    }
    
    open func getMapView() -> Any {
        return self.mapView
    }
    
    public func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation else { return }
        
        var region: MKCoordinateRegion
        if zoom {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        } else {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom))
        }
        
        mapView.setRegion(region, animated: true)
    }
    
    public func addAnnotations(annotations: [MLAnnotation]) {
        DispatchQueue.main.async {
            // Let cluster manager manage clusters after loading all annotations
            self.clusterMgr.add(annotations)
            self.clusterMgr.reload(mapView: self.mapView)
        }
    }
    
    public func removeAnnotation(annotation: MLAnnotation) {
        self.mapView.removeAnnotation(annotation)
    }
    
    public func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        clusterMgr.removeAll()
    }
    
    public func refreshMap(completion: ((Bool) -> Void)? = nil) {
        if let completion = completion {
            clusterMgr.reload(mapView: mapView, completion: completion)
        } else {
            clusterMgr.reload(mapView: mapView)
        }
    }
    
    internal func cleanUpMapMemory() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.delegate = nil
        mapView.showsUserLocation = false
        mapView.removeFromSuperview()
        mapView = nil
        clusterMgr.removeAll()
    }
    
    /**
     Clean up memory usage.
     */
    public func cleanUp() {
        cleanUpMapMemory()
        
        locationMgr?.stopUpdatingLocation()
        locationMgr?.delegate = nil
        locationMgr = nil
    }
    
    
    /**
     Setup LocationManager and start updating location.
     */
    public func setupLocationMgr() {
        self.locationMgr = CLLocationManager()
        if let manager = self.locationMgr {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.delegate = self
            manager.startUpdatingLocation()
        }
    }
    
    public func setMinCountForClustering(minCount: Int) {
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
            let identifier = "marker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view {
                view.annotation = annotation
            } else {
                if #available(iOS 11.0, *), let _ = annotation.annotBgColor {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
            }
            
            if #available(iOS 11.0, *), let annotBgColor = annotation.annotBgColor {
                (view as! MKMarkerAnnotationView).glyphImage = annotation.annotImg
                (view as! MKMarkerAnnotationView).markerTintColor = annotBgColor
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

// MARK: CLLocationManagerDelegate
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

// MARK: MapLoader built-in animations
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
