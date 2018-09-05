//
//  GoogleMapLoader.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 9/5/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import GoogleMaps

open class GoogleMapLoader: MapLoader {
    // MARK: - Variables accessible by other class
    open var gDefaultZoom: Float = 12.0
    /**
     The GoogleMapView used by MapLoader.
     */
    private var gMapView: GMSMapView!
    /**
     Init
     */
    public override init() {
        super.init()
        
        LOG_TAG = "[GoogleMapLoader] "
        setupLocationMgr()
    }
    /**
     Deserializing the object.
     */
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     Set API key
     */
    public static func setAPIKey(key: String) {
        GMSServices.provideAPIKey(key)
    }
    override open func getMapView() -> Any {
        return self.gMapView
    }
    override public func layoutMapView() {
        gMapView.frame = mapContainer.frame
    }
    override public func setupMapView(mapContainer: UIView, viewAboveMap: UIView?, delegate: Any?) {
        self.mapContainer = mapContainer
        var camera = GMSCameraPosition.camera(withLatitude: defaultLocation.latitude,
                                              longitude: defaultLocation.longitude,
                                              zoom: gDefaultZoom)
        if let location = self.mostRecentLocation {
            camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: gDefaultZoom)
        }
        gMapView = GMSMapView.map(withFrame: mapContainer.frame, camera: camera)
        gMapView.isMyLocationEnabled = true
        if let delegate = delegate as? GMSMapViewDelegate {
            gMapView.delegate = delegate
        }
        if let viewAboveMap = viewAboveMap {
            self.mapContainer.insertSubview(gMapView, belowSubview: viewAboveMap)
        } else {
            self.mapContainer.insertSubview(gMapView, at: 0)
        }
    }
    override public func showLocateButton(_ show: Bool) {
        gMapView.settings.myLocationButton = show
    }
    override public func centerCurrentLocation(zoom: Bool) {
        guard let location = mostRecentLocation, let mapView = gMapView else { return }
        let zoomLevel = zoom ? gDefaultZoom*1.5 : gDefaultZoom
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView.animate(to: camera)
    }
}
