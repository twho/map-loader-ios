//
//  StyledAnnotationView.swift
//  MapLoader
//
//  Created by Ho, Tsung Wei on 7/9/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import UIKit

open class StyledAnnotationView: UIView {
    
    let LOG_TAG = "[StyledAnnotationView] "
    
    @IBOutlet weak var annotBackground: UIImageView!
    @IBOutlet weak var annotImage: UIImageView!
    
    enum BackgroundImage {
        case iOSDefault
        case bubble
    }
    
    convenience init(image: AnnotationImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init()
        
        var bgImage = UIImage()
    }
    
    convenience init(image: UIImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init()
    }
    
    convenience init(image: UIImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init()
    }
    
//    private func getAnnotBackground(bgColor: UIColor?, background: BackgroundImage) -> UIImage {
//        
//    }
    
    public func getAnnotationImg() -> UIImage?{
        return UIImage(view: self)
    }
}

extension StyledAnnotationView {
    
    // For private project use
    enum AnnotationImage {
        case personalNote
        case publicNote
        case police
        case hazard
        case accident
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
