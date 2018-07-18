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
        Bundle.main.loadNibNamed("StyledAnnotationView", owner: self, options: nil)
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
    public convenience init(image: UIImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        annotImage.image = image
        annotImage.colored(color: color)
        annotBackground.image = background
        
        if let color = color {
            annotBackground.colored(color: bgColor)
            self.bgColor = color
        }
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the AnnotationImage type of the foreground image
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the BackgroundImage type of the background image
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(image: AnnotationImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init(image: ResManager.getAnnotImage(annotImage: image), color: color, background: ResManager.getBgImage(annotImage: background), bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the foreground image of the annotation view
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the BackgroundImage type of the background image
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(image: UIImage, color: UIColor?, background: BackgroundImage, bgColor: UIColor?) {
        self.init(image: image, color: color, background: ResManager.getBgImage(annotImage: background), bgColor: bgColor)
        customConstraints(bgType: background)
    }
    
    /**
     Initializer for using built-in image resources.
     
     - Paramter image:      the AnnotationImage type of the foreground image
     - Paramter color:      the color of the foreground image. Set nil to remain original image color
     - Paramter background: the background image of the annotation view
     - Paramter bgColor:    the color of the background image. Set nil to use default color
     */
    public convenience init(image: AnnotationImage, color: UIColor?, background: UIImage, bgColor: UIColor?) {
        self.init(image: ResManager.getAnnotImage(annotImage: image), color: color, background: background, bgColor: bgColor)
    }
    
    /**
     Initializer for setting built-in foreground and background images without specifying colors.
     
     - Paramter image:      the AnnotationImage type of the foreground image
     - Paramter background: the BackgroundImage type of the background image
     */
    public convenience init(image: AnnotationImage, background: BackgroundImage) {
        self.init(image: ResManager.getAnnotImage(annotImage: image), color: nil, background: ResManager.getBgImage(annotImage: background), bgColor: nil)
        customConstraints(bgType: background)
    }
    
    /**
     Initializer for setting foreground and background images without specifying colors.
     
     - Paramter image:      the foreground image of the annotation view
     - Paramter background: the background image of the annotation view
     */
    public convenience init(image: UIImage, background: UIImage) {
        self.init(image: image, color: nil, background: background, bgColor: nil)
    }
    
    /**
     Configure top constraints to react to specfic background images.
     
     - Parameter bgType: the BackgroundImage type of the background image
     */
    private func customConstraints(bgType: BackgroundImage) {
        annotImgTopConstraint.constant = bgType == .heart ? 5.0 : 6.0
        annotImgLeftConstraint.constant = bgType == .heart ? 10.0 : 8.0
        annotImgRightConstraint.constant = bgType == .heart ? 10.0 : 8.0
        self.layoutIfNeeded()
    }
    
    /**
     Convert UIView to UIImage without losing quality. Refer to Tom Harte on StackOverflow.
     
     - Returns nil or an UIImage converted from UIView
     */
    public func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        self.annotImage.image = ResManager.getAnnotImage(annotImage: .error)
        self.backgroundColor = UIColor.red
        return self.toImage()
    }
}

// MARK: Built-in image resources
extension StyledAnnotationView {

    /**
     Built-in annotation images.
     
     - error:        error image
     - police:       police image
     - hazard:       road hazard image
     - construction: road under construction image
     */
    public enum AnnotationImage {
        case error
        case police
        case hazard
        case construction
        case crash
        case multiUser
        case personal
        case gas
        case charging
    }
    
    /**
     Built-in background images.
     
     - bubble: bubble background
     - square: square-shaped background
     - circle: circular background
     - heart:  heart-shaped background
     - flag:   flag background
     */
    public enum BackgroundImage {
        case bubble
        case square
        case circle
        case heart
        case flag
    }
}

// MARK: UIImageView
extension UIImageView {
    /**
     Change the color of the image.
     
     - Parameter color: the color to be set to the image
     */
    func colored(color: UIColor?) {
        guard let color = color else { return }
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
