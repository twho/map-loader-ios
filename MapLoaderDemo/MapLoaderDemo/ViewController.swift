//
//  ViewController.swift
//  MapLoaderDemo
//
//  Created by Ho, Tsung Wei on 9/5/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var mapLoader: MapLoader!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapLoader = GoogleMapLoader()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapLoader.setupMapView(mapContainer: self.view, viewAboveMap: nil, delegate: self)
        mapLoader.showMyLocationButton = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set mapView fill the screen and assign the delegate
        mapLoader.layoutMapView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

