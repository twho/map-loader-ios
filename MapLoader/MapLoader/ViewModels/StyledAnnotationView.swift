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
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var annotBackground: UIImageView!
    @IBOutlet weak var annotImage: UIImageView!
    @IBOutlet weak var annotImgTopConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StyledAnnotationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer for general use
    public convenience init(image: UIImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        annotImage.image = image
        annotImage.colored(color: color)
        annotBackground.image = background
        annotBackground.colored(color: bgColor)
    }
    
    public convenience init(image: AnnotationImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init(image: image.image, color: color, background: background.image, bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    public convenience init(image: UIImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init(image: image, color: color, background: background.image, bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    public convenience init(image: AnnotationImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init(image: image.image, color: color, background: background, bgColor: bgColor)
    }
    
    public convenience init(image: AnnotationImage, background: BackgroundImage) {
        self.init(image: image.image, color: nil, background: background.image, bgColor: nil)
        customConstraints(bgType: background)
    }
    
    public convenience init(image: UIImage, background: UIImage) {
        self.init(image: image, color: nil, background: background, bgColor: nil)
    }
    
    private func customConstraints(bgType: BackgroundImage) {
        annotImgTopConstraint.constant = bgType == .heart ? 3.5 : 6.0
        self.layoutIfNeeded()
    }
    
    /**
     Convert UIView to UIImage without losing quality
     Solution from Tom Harte on stack overflow
     
     - Returns nil or an UIImage converted from UIView
     */
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        self.annotImage.image = AnnotationImage.error.image
        self.backgroundColor = UIColor.red
        return self.toImage()
    }
}

// Handle built-in images
extension StyledAnnotationView {
    
    // For private project use
    public enum AnnotationImage {
        case error
        case police
        
        var image: UIImage {
            switch self {
            case .error: return UIImage(named: "ic_error")!
            case .police: return UIImage(named: "ic_sample1")!
            }
        }
    }
    
    // Default background images
    public enum BackgroundImage {
        case bubble
        case square
        case circle
        case heart
        case flag
        
        var image: UIImage {
            switch self {
            case .bubble: return UIImage(named: "ic_annot1")!
            case .square: return UIImage(named: "ic_annot2")!
            case .circle: return UIImage(named: "ic_annot3")!
            case .heart: return UIImage(named: "ic_annot4")!
            case .flag: return UIImage(named: "ic_annot5")!
            }
        }
    }
}

extension UIImageView {
    func colored(color: UIColor?) {
        guard let color = color else { return }
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
