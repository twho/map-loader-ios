//
//  MLAnnotation.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/5/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import CoreLocation

// Map loader annotation
open class MLAnnotation: Annotation {
    open var annotImg: UIImage?
    open var annotBgColor: UIColor?
    open var data: Any?
    
    public init(coordinate: CLLocationCoordinate2D, annotImg: UIImage?, annotBgColor: UIColor?, data: Any?) {
        super.init()
        
        self.coordinate = coordinate
        self.annotImg = annotImg
        self.annotBgColor = annotBgColor
        self.data = data
    }
}
