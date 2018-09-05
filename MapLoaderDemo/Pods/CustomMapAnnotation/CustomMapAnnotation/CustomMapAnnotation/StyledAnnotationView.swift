//
//  StyledAnnotationView.swift
//  CustomMapAnnotation
//
//  Created by Ho, Tsung Wei on 7/9/18.
//  Copyright © 2018 Michael T. Ho. All rights reserved.
//

import UIKit

open class StyledAnnotationView: UIView {
    /**
     The entire annotation view.
     */
    @IBOutlet var contentView: UIView!
    
    /**
     The background as UIImageView of the annotation view.
     */
    @IBOutlet weak var annotBackground: UIImageView!
    
    /**
     The foreground as UIImageView of the annotation view.
     */
    @IBOutlet weak var annotImage: UIImageView!
    
    /**
     The top constraint of the foreground image of the annotation view.
     */
    @IBOutlet weak var annotImgTopConstraint: NSLayoutConstraint!
    
    /**
     The left constraint of the foreground image of the annotation view.
     */
    @IBOutlet weak var annotImgLeftConstraint: NSLayoutConstraint!
    
    /**
     The right constraint of the foreground image of the annotation view.
     */
    @IBOutlet weak var annotImgRightConstraint: NSLayoutConstraint!
    
    /**
     Background color
     */
    public var bgColor = UIColor(white: 1, alpha: 0.1)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    /**
     Configure for the StyledAnnotationView.
     */
    private func configure() {
        CMAResManager.getBundle(bundleType: .viewNibs).loadNibNamed("StyledAnnotationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    /**
     Deserializing the object.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Initializer for general use.
     
     - Paramter image:      the foreground image of the annotation view
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the background image of the annotation view
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(annotImg: UIImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        annotImage.image = annotImg
        annotImage.colored(color: color)
        annotBackground.image = background
        
        if let bgColor = bgColor {
            annotBackground.colored(color: bgColor)
            self.bgColor = bgColor
        }
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the AnnotationImage type of the foreground image
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the BackgroundImage type of the background image
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(annotImg: CMAResManager.annotImg, color: UIColor? = nil, background: CMAResManager.BgImg, bgColor: UIColor? = nil) {
        self.init(annotImg: annotImg.image, color: color, background: background.image, bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the foreground image of the annotation view
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the BackgroundImage type of the background image
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(annotImg: UIImage, color: UIColor? = nil, background: CMAResManager.BgImg, bgColor: UIColor? = nil) {
        self.init(annotImg: annotImg, color: color, background: background.image, bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the AnnotationImage type of the foreground image
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the background image of the annotation view
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(annotImg: CMAResManager.annotImg, color: UIColor? = nil, background: UIImage, bgColor: UIColor? = nil) {
        self.init(annotImg: annotImg.image, color: color, background: background, bgColor: bgColor)
    }
    
    /**
     Initializer for setting foreground and background images without specifying colors.
     
     - Paramter image:      the foreground image of the annotation view
     - Paramter background: the background image of the annotation view
     */
    public convenience init(annotImg: UIImage, background: UIImage) {
        self.init(annotImg: annotImg, color: nil, background: background, bgColor: nil)
    }
    
    /**
     Configure top constraints to react to specfic background images.
     
     - Parameter bgType: the BackgroundImage type of the background image
     */
    private func customConstraints(bgType: CMAResManager.BgImg) {
        annotImgTopConstraint.constant = (bgType == .heart || bgType == .circle)  ? 5.0 : 6.0
        annotImgLeftConstraint.constant = bgType == .heart ? 9.0 : 8.0
        annotImgRightConstraint.constant = bgType == .heart ? 9.0 : 8.0
        self.layoutIfNeeded()
    }
    
    /**
     Convert UIView to UIImage without losing quality. Refer to Tom Harte on StackOverflow.
     
     - Returns nil or an UIImage converted from UIView
     */
    public func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        
        self.annotImage.image = CMAResManager.annotImg.error.image
        self.backgroundColor = UIColor.red
        return self.toImage()
    }
}
