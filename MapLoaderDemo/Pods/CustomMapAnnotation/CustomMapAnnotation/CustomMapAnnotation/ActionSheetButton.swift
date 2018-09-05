//
//  AudioButton.swift
//  CustomMapAnnotation
//
//  Created by Michael Ho on 7/19/18.
//  Copyright (c) 2018 Michael Ho. All rights reserved.
//

import UIKit

@IBDesignable
open class ActionSheetButton: LoadingButton {
    /**
     Background color set.
     */
    open var bgColor = (normal: UIColor.white, clicked: CMAResManager.Color.ltGray, disabled: CMAResManager.Color.gray)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Rounded corner
        layer.cornerRadius = 10.0
        clipsToBounds = true
        
        setButtonStyle(normal: bgColor.normal, clicked: bgColor.clicked, disabled: bgColor.disabled)
    }
    
    /**
     Set button colors for different states.
     
     - Parameters:
        - normal:   The color for normal state.
        - clicked:  The color when the button is clicked/highlighted.
        - disabled: The color when the button is disabled.
     */
    public func setButtonStyle(normal: UIColor, clicked: UIColor, disabled: UIColor) {
        setBackgroundImage(UIImage(color: normal), for: .normal)
        setBackgroundImage(UIImage(color: clicked), for: .highlighted)
        setImage(self.currentImage?.colored(color: disabled), for: .disabled)
    }
}

// Created by Romilson Nunes on 06/06/14.
// MARK: - LoadingButton
@IBDesignable
open class LoadingButton: UIButton {
    
    /**
     Loading state
     */
    @IBInspectable open var isLoading: Bool = false {
        didSet {            
            #if !TARGET_INTERFACE_BUILDER
                configureControl(for: currentControlState())
            #else
                self.setNeedsDisplay()
            #endif
        }
    }
    
    /**
     Hide image when loading is visible.
     */
    @IBInspectable open var hideImageWhenLoading: Bool = true {
        didSet {
            configureControl(for: currentControlState())
        }
    }
    
    /**
     Hide text when loading is visible.
     */
    @IBInspectable open var hideTextWhenLoading: Bool = true {
        didSet {
            configureControl(for: currentControlState())
        }
    }
    
    /**
     Activity Indicator style. Default is .gray.
     */
    open var activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /**
     Color to activityIndicatorView. Default is nil.
     */
    @IBInspectable open var activityIndicatorColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }

    
    // Internal properties
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    typealias ControlStateDictionary = [UInt: Any]
    
    fileprivate var images = ControlStateDictionary()
    fileprivate var titles = ControlStateDictionary()
    fileprivate var attributedTitles = ControlStateDictionary()
    
    
    // MARK: - Initializers
    
    #if !TARGET_INTERFACE_BUILDER

    deinit {
        self.removeObservers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupActivityIndicator()
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        setupActivityIndicator()
        
        let states: [UIControlState] = [.normal, .highlighted, .disabled, .selected]
        
        // Store default values
        _ = states.map({
            
            // Images - Icons
            if let imageForState = super.image(for: $0) {
                self.store(imageForState, in: &self.images, for: $0)
            }
            
            // Title - Texts
            if let titleForState = super.title(for: $0) {
                self.store(titleForState, in: &self.titles, for: $0)
            }
            
            // Attributed Title - Texts
            if let attributedTitle = super.attributedTitle(for: $0) {
                self.store(attributedTitle, in: &self.attributedTitles, for: $0)
            }
            
        })
        
        configureControl(for: currentControlState())
    }
    
    #endif
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        #if !TARGET_INTERFACE_BUILDER
            // this code will run in the app itself
        #else
            // this code will execute only in IB
            self.setupActivityIndicator()
            configure()
        #endif
    }
    
    
    // MARK: - Initializers Helpers
    fileprivate func configure() {
        self.adjustsImageWhenHighlighted = true
        self.storeDefaultValues()
        #if !TARGET_INTERFACE_BUILDER
            self.addObservers()
        #endif
    }
    
    fileprivate func storeDefaultValues() {
        let states: [UIControlState] = [.normal, .highlighted, .disabled, .selected]
        _ = states.map({
            // Images for State
            self.images[$0.rawValue] = super.image(for: $0)
            
            // Title for States
            self.titles[$0.rawValue] = super.title(for: $0)
            
            /// Attributed Title for States
            self.attributedTitles[$0.rawValue] = super.attributedTitle(for: $0)
        })
    }
    
    // MARK: - Relayout
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.activityIndicatorView.activityIndicatorViewStyle = self.activityIndicatorViewStyle
        self.activityIndicatorView.color = self.activityIndicatorColor
        self.activityIndicatorView.frame = self.frameForActivityIndicator()
        self.bringSubview(toFront: self.activityIndicatorView)
    }

    
    // MARK: - Internal Methods
    fileprivate func setupActivityIndicator() {
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.startAnimating()
        self.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.isUserInteractionEnabled = false
    }
    
    fileprivate  func currentControlState() -> UIControlState {
        var controlState = UIControlState.normal.rawValue
        if self.isSelected {
            controlState += UIControlState.selected.rawValue
        }
        if self.isHighlighted {
            controlState += UIControlState.highlighted.rawValue
        }
        if !self.isEnabled {
            controlState += UIControlState.disabled.rawValue
        }
        return UIControlState(rawValue: controlState)
    }
    
    fileprivate func setControlState(_ value: AnyObject, dic: inout ControlStateDictionary, state: UIControlState) {
        dic[state.rawValue] = value
        configureControl(for: currentControlState())
    }
    
    fileprivate func setImage(_ image:UIImage, state:UIControlState) {
        setControlState(image, dic: &self.images, state: state)
    }
    
    
    // MARK: - Override Setters & Getters
    override open func setTitle(_ title: String?, for state: UIControlState) {
        self.store(title, in: &self.titles, for: state)
        if super.title(for: state) != title {
            super.setTitle(title, for: state)
        }
        self.setNeedsLayout()
    }
    
    open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
        self.store(title, in: &self.attributedTitles, for: state)
        if super.attributedTitle(for: state) != title {
            super.setAttributedTitle(title, for: state)
        }
        self.setNeedsLayout()
    }
    
    override open func setImage(_ image: UIImage?, for state: UIControlState) {
        self.store(image, in: &self.images, for: state)
        if super.image(for: state) != image {
            super.setImage(image, for: state)
        }
        self.setNeedsLayout()
    }
    
    override open func title(for state: UIControlState) -> String?  {
        return getValueFrom(type: String.self, on: self.titles, for: state)
    }
    
    open override func attributedTitle(for state: UIControlState) -> NSAttributedString? {
        return getValueFrom(type: NSAttributedString.self, on: self.attributedTitles, for: state)
    }
    
    override open func image(for state: UIControlState) -> UIImage? {
        return getValueFrom(type: UIImage.self, on: self.images, for: state)
    }
    
    
    // MARK: -  Private Methods
    fileprivate func configureControl(for state: UIControlState) {
        if self.isLoading {
            self.activityIndicatorView.startAnimating()
            
            if self.hideImageWhenLoading {
                
                var imgTmp: UIImage? = nil
                if let img = self.image(for: UIControlState.normal) {
                    imgTmp = img.getClearImage()
                }
                
                super.setImage(imgTmp, for: UIControlState.normal)
                super.setImage(imgTmp, for: UIControlState.selected)
                super.setImage(imgTmp, for: state)
                super.imageView?.image = imgTmp
                
            } else {
                super.setImage( self.image(for: state), for: state)
            }
            
            if (self.hideTextWhenLoading) {
                super.setTitle(nil, for: state)
                super.setAttributedTitle(nil, for: state)
                super.titleLabel?.text = nil
            } else {
                super.setTitle( self.title(for: state) , for: state)
                super.titleLabel?.text = self.title(for: state)
                super.setAttributedTitle(self.attributedTitle(for: state), for: state)
            }
        } else {
            self.activityIndicatorView.stopAnimating()
            super.setImage(self.image(for: state), for: state)
            super.imageView?.image = self.image(for: state)
            super.setTitle(self.title(for: state), for: state)
            super.titleLabel?.text = self.title(for: state)
            super.setAttributedTitle(self.attributedTitle(for: state), for: state)
        }
        
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    fileprivate func frameForActivityIndicator() -> CGRect {
        var frame:CGRect = CGRect.zero
        frame.size = self.activityIndicatorView.frame.size
        frame.origin.y = (self.frame.size.height - frame.size.height) / 2
        
        // Put the indicator to the center of the button
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2
        
        return frame
    }
    
    // MARK: -  Store and recorver values
    /** Value in Dictionary for control State */
    fileprivate func getValueFrom<T>(type: T.Type, on dic: ControlStateDictionary, for state: UIControlState) -> T? {
        if let value =  dic[state.rawValue] as? T {
            return value
        }
        return dic[UIControlState.normal.rawValue] as? T
    }
    
    fileprivate func store<T>(_ value: T?, in dic: inout ControlStateDictionary, for state: UIControlState) {
        if let _value = value as AnyObject?  {
            dic[state.rawValue] = _value
        }
        else {
            dic.removeValue(forKey: state.rawValue)
        }
    }
    
    
    // MARK: - Key-value Observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        configureControl(for: currentControlState())
    }
    
}

// MARK: - Observer
fileprivate extension LoadingButton {

    fileprivate func addObservers() {
        self.addObserver(forKeyPath: "self.state")
        self.addObserver(forKeyPath: "self.selected")
        self.addObserver(forKeyPath: "self.highlighted")
    }

    fileprivate func removeObservers() {
        self.removeObserver(forKeyPath: "self.state")
        self.removeObserver(forKeyPath: "self.selected")
        self.removeObserver(forKeyPath: "self.highlighted")
    }

    fileprivate func addObserver(forKeyPath keyPath:String) {
        self.addObserver(self, forKeyPath:keyPath, options: ([NSKeyValueObservingOptions.initial, NSKeyValueObservingOptions.new]), context: nil)
    }
    
    fileprivate func removeObserver(forKeyPath keyPath: String!) {
        self.removeObserver(self, forKeyPath: keyPath)
    }
}
