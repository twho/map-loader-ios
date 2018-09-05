//
//  Extensions.swift
//  LocationAudioMessage
//
//  Created by Ho, Tsung Wei on 7/18/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Create color rectangle as image.
     
     - Parameters:
        - color: the color to be created as an UIImage
        - size:  the size of the UIImage, no need to be set when creating
     */
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil}
        self.init(cgImage: cgImage)
    }
    
    /**
     Clear image.
     
     - Parameters:
        - size:  The size of the UIImage
        - scale: The scale of the output UIImage
     */
    public func getClearImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        UIGraphicsPopContext()
        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        
        return  UIImage(cgImage: outputImage.cgImage!, scale: scale, orientation: UIImageOrientation.up)
    }
    
    /**
     Change the color of the image.
     
     - Parameter color: The color to be set to the UIImage.
     
     Returns an UIImage with specified color
     */
    public func colored(color: UIColor?) -> UIImage? {
        if let newColor = color {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            
            newColor.setFill()
            context.fill(rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            newImage.accessibilityIdentifier = accessibilityIdentifier
            return newImage
        }
        
        return self
    }
    
    /**
     Load images from bundle class.
     
     - Parameters:
     - name: Image full name.
     
     Returns an image loaded as UIImage or nil
     */
    public static func make(named: String) -> UIImage? {
        let bundle = CMAResManager.getBundle(bundleType: .resources)
        return UIImage(named: "\(named)", in: bundle, compatibleWith: nil)
    }
}

// MARK: - UIImageView
extension UIImageView {
    /**
     Change the color of the image.
     
     - Parameter color: The color to be set to the UIImageView.
     */
    public func colored(color: UIColor?) {
        guard let color = color else { return }
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

// MARK: - UIButton
extension UIButton {
    
    /**
     Init with customized parameters.
     
     - Parameters:
        - frame:        The frame of the button.
        - title:        Title text content.
        - titleColor:   Title color pair. One for normal state and the other one for hightlighted.
        - bgColor:      Background color pair. One for normal state and the other one for hightlighted.
        - cornerRadius: the corner radius of the button. Input value if needs rounded corner.
     */
    public convenience init(frame: CGRect, title: String, titleColor: (UIColor, UIColor) = (UIColor.white, UIColor.gray), bgColor: (UIColor, UIColor) = (UIColor.white, UIColor.gray), cornerRadius: CGFloat? = nil) {
        self.init(frame: frame)
        
        if let cornerRadius = cornerRadius {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
        
        self.setTitle(title, for: UIControlState())
        self.setTitleColor(titleColor.0, for: UIControlState())
        self.setTitleColor(titleColor.1, for: .highlighted)
        self.setBackgroundImage(UIImage(color: bgColor.0), for: .normal)
        self.setBackgroundImage(UIImage(color: bgColor.1), for: .highlighted)
    }
    
    /**
     Set button image for all button states
     
     - Parameter image: the image to be set to the button.
     */
    public func setImageForAllState(image: UIImage){
        for state: UIControlState in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
            self.setImage(image, for: state)
        }
    }
}

// MARK: - UIColor
extension UIColor {
    
    /**
     Convert RGB value to CMYK value.
     
     - Parameters:
        - r: The red value of RGB.
        - g: The green value of RGB.
        - b: The blue value of RGB.
     
     Returns a 4-tuple that represents the CMYK value converted from input RGB.
     */
    private func RGBtoCMYK(r: CGFloat, g: CGFloat, b: CGFloat) -> (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        
        if r==0, g==0, b==0 {
            return (0, 0, 0, 1)
        }
        var c = 1 - r
        var m = 1 - g
        var y = 1 - b
        let minCMY = min(c, m, y)
        c = (c - minCMY) / (1 - minCMY)
        m = (m - minCMY) / (1 - minCMY)
        y = (y - minCMY) / (1 - minCMY)
        return (c, m, y, minCMY)
    }
    
    /**
     Convert CMYK value to RGB value.
     
     - Parameters:
         - c: The cyan value of CMYK.
         - m: The magenta value of CMYK.
         - y: The yellow value of CMYK.
         - k: The key/black value of CMYK.
     
     Returns a 3-tuple that represents the RGB value converted from input CMYK.
     */
    private func CMYKtoRGB(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let r = (1 - c) * (1 - k)
        let g = (1 - m) * (1 - k)
        let b = (1 - y) * (1 - k)
        return (r, g, b)
    }
    
    /**
     Get dark color tint of the specified color.
     
     Returns a darker color converted from specified color.
     */
    public func getDarkColorTint() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        let tintRGB = CMYKtoRGB(c: originCMYK.c, m: originCMYK.m, y: originCMYK.y, k: min(1.0, originCMYK.k + 0.15))
        
        return UIColor(red: tintRGB.r, green: tintRGB.g, blue: tintRGB.b, alpha: 1.0)
    }
    
    /**
     Get lighter color tint of the specified color.
     
     Returns a lighter color converted from specified color.
     */
    public func getLtColorTint() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        let tintRGB = CMYKtoRGB(c: originCMYK.c, m: originCMYK.m, y: originCMYK.y, k: max(0, originCMYK.k - 0.15))
        
        return UIColor(red: tintRGB.r, green: tintRGB.g, blue: tintRGB.b, alpha: 1.0)
    }
    
    /**
     Get inferred text color based on specified color.
     
     Returns the inferred color.
     */
    public func getAppropriateTextColor() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(r: ciColor.red, g: ciColor.green, b: ciColor.blue)
        if originCMYK.k > 60 {
            return UIColor.darkGray
        } else {
            return UIColor.white
        }
    }
}
