//
//  MapLoaderProtocol.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/17/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit
import CoreLocation

protocol MapLoaderVariables {
    var defaultZoom: Double { get set }
    var clusterColor: UIColor { get set }
    var isLocationButtonShown: Bool { get set }
    /**
     The UIView container to contain the map.
     */
    var mapContainer: UIView? { get set }
    /**
     The most recent location updated by LocationManager.
     */
    var mostRecentLocation: CLLocation? { get set }
    /**
     Flag that indicates if the map is zoom in already.
     */
    var didDefaultZoomIn: Bool { get set }
    /**
     The default location to show if MapLoader cannot retrieve location from LocationManager.
     */
    var defaultLocation: CLLocationCoordinate2D { get set }
    /**
     The cluster manager for clustering annotations.
     */
    var clusterMgr: ClusterManager { get set }
}
// MARK: - MapLoaderFunction protocol
/**
 The protocol that defines the functions that a MapLoader should have and implement.
 */
protocol MapLoaderFunction {
    /**
     Set default zoom value.
     
     - Parameter value: the default zoom in float value
     */
    func setDefaultZoom(_ value: Double)
    
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
     Show location button.
     
     - Parameter show: Set true to show locate button. Set false to hide the button
     */
    func showLocateButton(_ show: Bool)
    
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
    func addAnnotations(_ annotations: [MLAnnotation])
    
    /**
     Remove all annotations.
     */
    func removeAllAnnotations()
    
    /**
     Remove certain annotation from the MapView.
     
     - Parameter annotation: the annotation to be removed from the map
     */
    func removeAnnotation(_ annotation: MLAnnotation)
    
    /**
     Refresh annotations on the MapView.
     
     - Paramter completion: the task to perform after map finished refresing. Set nil if there is no task
     */
    func refreshMap(completion: ((Bool)->Void)?)
    
    /**
     Set maximum zoom level to stop clustering.
     
     - Parameter maxZoom: the maximum zoom level to stop clustering
     */
    func setMaxZoomLevel(_ maxZoom: Double)
    
    /**
     Get current zoom level.
     
     Returns a double value represents current zoom level
     */
    func getCurrentZoomLevel() -> Double
    
    /**
     Clean up memory used by the MapView and mapLoader.
     */
    func cleanUpMapMemory()
}

// MARK: - MapClusterFunction protocol
/**
 The protocol defines the functions that a MapLoader using annotation clustering should implement.
 */
protocol MapClusterFunction {
    
    /**
     Set minimum cluster count.
     
     - Parameter minCount: the minimum count for clustering annotations
     */
    func setMinCountForClustering(_ minCount: Int)
    
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
