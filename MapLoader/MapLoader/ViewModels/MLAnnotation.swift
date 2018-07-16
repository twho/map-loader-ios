//
//  MLAnnotation.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/5/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit
import CoreLocation

// Map loader annotation
open class MLAnnotation: Annotation {
    open var annotImg: UIImage?
    open var annotBgColor: UIColor?
    open var data: Any?
    
    /**
     Init annotation view with a foreground image with a background color set on annotation view
     
     - Parameter coordinate: the geo-location of the annotation
     - Parameter annotImg: the foreground image of the annotation
     - Parameter annotBgColor: the background color of the annotation
     - Parameter data: data in any type that are stored with annotation
     */
    public init(coordinate: CLLocationCoordinate2D, annotImg: UIImage?, annotBgColor: UIColor?, data: Any?) {
        super.init()
        
        self.coordinate = coordinate
        self.annotImg = annotImg
        self.annotBgColor = annotBgColor
        self.data = data
    }
    
    /**
     Init annotation view with a image that represents the whole annotation view
     
     - Parameter coordinate: the geo-location of the annotation
     - Parameter annotImg: the image of the entire annotation view without any additional background
     */
    public init(coordinate: CLLocationCoordinate2D, annotImg: UIImage?, data: Any?) {
        super.init()
        
        self.coordinate = coordinate
        self.annotImg = annotImg
        self.data = data
    }
}
