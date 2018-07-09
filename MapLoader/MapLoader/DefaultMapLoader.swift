//
//  DefaultMapLoader.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/4/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//
//  Used Cluster from efremidze on Github, current version 2.2.4
//

import MapKit

public class DefaultMapLoader: MapLoader {
    
    // In-class variables
    private var defaultZoom = 0.03
    private var mapView: MKMapView!
    private let clusterMgr = ClusterManager()
    
    override public init() {
        super.init()
        
        LOG_TAG = "[DefaultMapLoader] "
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setDefaultZoom(_ value: Float) {
        defaultZoom = Double(value)
    }
    
    // Should be put in viewDidLayoutSubviews()
    override public func layoutMapView() {
        mapView.frame = mapContainer.frame
    }
    
    override public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
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
    
    override public func getMapView() -> Any {
        return mapView
    }
    
    override public func refreshMap() {
        clusterMgr.reload(mapView: mapView)
    }
    
    override public func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation else { return }
        
        var region: MKCoordinateRegion
        if zoom {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        } else {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom))
        }
        
        mapView.setRegion(region, animated: true)
    }
    
    override public func addAnnotations(annotations: [MLAnnotation]) {
        DispatchQueue.main.async {
            // Let cluster manager manage clusters after loading all annotations
            self.clusterMgr.add(annotations)
            self.clusterMgr.reload(mapView: self.mapView)
        }
    }
    
    override public func removeAnnotation(annotation: MLAnnotation) {
        self.mapView.removeAnnotation(annotation)
    }
    
    override public func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        clusterMgr.removeAll()
    }
    
    override public func setMinCountForClustering(minCount: Int) {
        clusterMgr.minCountForClustering = minCount
    }
    
    override public func cleanUpMapMemory() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.delegate = nil
        mapView.showsUserLocation = false
        mapView.removeFromSuperview()
        mapView = nil
        clusterMgr.removeAll()
    }
    
    override public func generateClusteringView(annotation: Any) -> UIView? {
        // Decide if annotation appears to be as an annotation or cluster
        if let annotation = annotation as? ClusterAnnotation {
            guard let style = annotation.style else { return nil }
            
            let identifier = "cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? BorderedClusterAnnotationView {
                view.annotation = annotation
                view.configure(with: .color(clusterColor, radius: 25))
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
                if #available(iOS 11.0, *) {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
            }
            
            if #available(iOS 11.0, *) {
                (view as! MKMarkerAnnotationView).glyphImage = annotation.annotImg
                (view as! MKMarkerAnnotationView).markerTintColor = annotation.annotBgColor
            } else {
                view?.image = annotation.annotImg
            }
            
            return view
        }
        
        return nil
    }
}

