//
//  MLAnnotation.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/5/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CustomMapAnnotation

// MapLoader annotation
open class MLAnnotation: Annotation {
    
    /**
     The foreground or entire image of the annotation.
     */
    open var annotImg: UIImage?
    
    /**
     The background color of the annotation.
     */
    open var annotBgColor: UIColor?
    
    /**
     The data to be stored with the annotation object.
     */
    open var data: Any?
    
    /**
     Flag to determine if display customized callout view
     */
    open var isExpanded = false
    
    /**
     Flag to determine if use iOS default annotation view
     */
    open var useDefaultView = false
    
    /**
     Init annotation view with a foreground image with a background color set on annotation view.
     
     - Parameter coordinate:     the geo-location of the annotation
     - Parameter annotImg:       the foreground image of the annotation
     - Parameter annotBgColor:   the background color of the annotation
     - Parameter data:           data in any type that are stored with annotation
     - Parameter useDefaultView: set true to use iOS default annotation view
     */
    public init(coordinate: CLLocationCoordinate2D, annotImg: UIImage?, annotBgColor: UIColor?, data: Any?, useDefaultView: Bool = false) {
        super.init()
        
        self.coordinate = coordinate
        self.annotImg = annotImg
        self.annotBgColor = annotBgColor
        self.useDefaultView = useDefaultView
        self.data = data
    }
    
    /**
     Init annotation view with StyledAnnotationView class.
     
     - Parameter coordinate: the geo-location of the annotation
     - Parameter annotView:  the StyledAnnotationView of the annotation
     - Parameter data:       data in any type that are stored with annotation
     */
    public init(coordinate: CLLocationCoordinate2D, annotView: StyledAnnotationView, data: Any?) {
        super.init()
        
        self.coordinate = coordinate
        self.annotImg = annotView.toImage()
        self.annotBgColor = annotView.bgColor
        self.useDefaultView = false
        self.data = data
    }
}

// MARK: BorderedClusterAnnotationView
open class BorderedClusterAnnotationView: ClusterAnnotationView {
    /**
     The border color of the cluster icon.
     */
    let borderColor: UIColor
    
    /**
     Init the object.
     
     - Parameter annotation:      the cluster annotation to generate view
     - Parameter reuseIdentifier: the string identifier
     - Parameter style:           style of annotation view
     - Parameter color:           color of the annotation view
     */
    public init(annotation: MKAnnotation?, reuseIdentifier: String?, style: ClusterAnnotationStyle, borderColor: UIColor) {
        self.borderColor = borderColor
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, style: style)
        configureBorder(style: style)
    }
    
    /**
     Deserializing the object.
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Configure style and border.
     
     - Parameter: style of the cluster annotation
     */
    func configureBorder(style: ClusterAnnotationStyle) {
        super.configure()
        
        switch style {
        case .image:
            layer.borderWidth = 0
        case .color:
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 2
        }
    }
}
