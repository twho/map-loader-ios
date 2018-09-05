//
//  CustomActionSheet.swift
//  CustomMapAnnotation
//
//  Created by Ryuta Kibe on 12/22/2015.
//  Updatrd by Michael Ho on 7/11/2018.
//  Copyright 2015 blk. All rights reserved.
//
import UIKit

/**
 Supported action shett view type
 */
public enum CustomActionSheetItemType: Int {
    case button
    case view
}

// MARK: - CustomActionSheetItem
open class CustomActionSheetItem: NSObject {
    
    // MARK: - Public properties
    public var type: CustomActionSheetItemType = .button
    public var height: CGFloat = defaultHeight
    public static let defaultHeight: CGFloat = 44
    
    // type = .View
    public var view: UIView?
    
    // type = .Button
    public let cornerRadius: CGFloat = 10
    public var title: String?
    public var titleColor: UIColor = UIColor(red: 0, green: 0.47, blue: 1.0, alpha: 1.0) // Default color
    public var backgroundColor: UIColor = UIColor.white
    public var backgroundTintColor: UIColor = CMAResManager.Color.gray
    public var font: UIFont? = nil
    public var onClick: ((_ actionSheet: CustomActionSheet) -> Void)? = nil
    
    // MARK: - Private properties
    fileprivate var element: UIView? = nil
    
    public convenience init(type: CustomActionSheetItemType, height: CGFloat = CustomActionSheetItem.defaultHeight) {
        self.init()
        
        self.type = type
        self.height = height
    }
    
    /**
     Init custom action sheet button.
     
     - Parameters:
        - height:     The height of the action sheet item
        - title:      The text of the action sheet item
        - titleColor: The color of the action sheet item
        - bgColor:    The background color pair. One for normal state and the other for highlighted state
        - onClick:    The task to be performed when the button is clicked
     */
    public convenience init(height: CGFloat = CustomActionSheetItem.defaultHeight, title: String, titleColor: UIColor?, bgColor: (color: UIColor, tint: UIColor)?, onClick: @escaping ((CustomActionSheet) -> Void)) {
        self.init()
        
        self.type = .button
        self.height = height
        self.title = title
        if let titleColor = titleColor {
            self.titleColor = titleColor
        }
        
        if let bgColor = bgColor {
            self.backgroundColor = bgColor.color
            self.backgroundTintColor = bgColor.tint
        }
        
        self.onClick = onClick
    }
}

// MARK: - ActionSheetItemView
private class ActionSheetItemView: UIView {
    var subview: UIView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.clipsToBounds = true
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        self.subview = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let subview = self.subview {
            subview.frame = self.bounds
        }
    }
}

// MARK: - CustomActionSheet
public class CustomActionSheet: NSObject {
    
    // MARK: - Public properties
    open var cornerRadius: CGFloat = 10
    open var viewGap: CGFloat = 8
    open var marginBottom: CGFloat = 12
    
    // MARK: - Private properties
    private static var actionSheets = [CustomActionSheet]()
    private let marginSide: CGFloat = 8
    private let marginTop: CGFloat = 20
    private var items: [CustomActionSheetItem]?
    private let maskView = UIView()
    private var darkBackground = true
    private let itemContainerView = UIView()
    private var closeBlock: (() -> Void)?
    
    /**
     Show custom action sheet.
     
     - Parameters:
        - targetView:       the parent view to show action sheet
        - items:            action sheet item such as buttons
        - gestureDismissal: set true to dismiss when tap elsewhere on screen
        - darkBackground:   set true to make background dark when open up action sheet
        - closeBlock:       task to perform after action sheet is closed
     */
    public func showInView(_ targetView: UIView, items: [CustomActionSheetItem], gestureDismissal: Bool, darkBackground: Bool = true, closeBlock: (() -> Void)? = nil) {
        // Save instance to reaction until closing this sheet
        CustomActionSheet.actionSheets.append(self)
        
        let targetBounds = targetView.bounds
        
        // Save closeBlock
        self.closeBlock = closeBlock
        
        // Add dismiss gesture
        if gestureDismissal {
            let maskViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomActionSheet.maskViewWasTapped))
            self.maskView.addGestureRecognizer(maskViewTapGesture)
            targetView.addGestureRecognizer(maskViewTapGesture)
        }
        
        self.darkBackground = darkBackground
        self.maskView.frame = targetBounds
        self.maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        targetView.addSubview(self.maskView)
        
        // Set items
        for subview in self.itemContainerView.subviews {
            subview.removeFromSuperview()
        }
        var currentPosition: CGFloat = 0.0
        var availableHeight = targetBounds.height - marginTop
        
        // Calculate height of items
        for item in items {
            availableHeight = availableHeight - item.height - viewGap
        }
        
        for item in items {
            // Apply height of items
            if availableHeight < 0 {
                let reduceNum = min(item.height, -availableHeight)
                item.height -= reduceNum
                availableHeight += reduceNum
                
                if item.height <= 0 {
                    availableHeight += viewGap
                    continue
                }
            }
            
            // Add views
            switch(item.type) {
            case .button:
                let frame = CGRect(x: marginSide, y: currentPosition, width: targetBounds.width - (marginSide * 2), height: item.height)
                
                let button = UIButton(frame: frame, title: item.title!, titleColor: (item.titleColor, UIColor.white), bgColor: (item.backgroundColor, item.backgroundTintColor), cornerRadius: cornerRadius)
                if let font = item.font {
                    button.titleLabel?.font = font
                }
                if let _ = item.onClick {
                    button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomActionSheet.buttonWasTapped(_:))))
                }
                item.element = button
                self.itemContainerView.addSubview(button)
            case .view:
                if let view = item.view {
                    let containerView = ActionSheetItemView(frame: CGRect(
                        x: marginSide,
                        y: currentPosition,
                        width: targetBounds.width - (marginSide * 2),
                        height: item.height))
                    containerView.layer.cornerRadius = cornerRadius
                    containerView.addSubview(view)
                    view.frame = view.bounds
                    self.itemContainerView.addSubview(containerView)
                    item.element = view
                }
            }
            
            // set current position
            currentPosition = currentPosition + item.height + viewGap
            
            if item == items.last {
                currentPosition += marginBottom
            }
            
        }
        
        self.itemContainerView.frame = CGRect(
            x: 0,
            y: targetBounds.height - currentPosition,
            width: targetBounds.width,
            height: currentPosition)
        self.items = items
        
        // Show animation
        self.maskView.alpha = 0
        targetView.addSubview(self.itemContainerView)
        
        let moveY = targetBounds.height - self.itemContainerView.frame.origin.y
        self.itemContainerView.transform = CGAffineTransform(translationX: 0, y: moveY)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        
                        if darkBackground {
                            self.maskView.alpha = 1
                        } else {
                            self.maskView.alpha = 0
                        }
                        self.itemContainerView.alpha = 0.97
                        self.itemContainerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    /**
     Dismiss action sheet.
     */
    public func dismiss() {
        guard let targetView = self.itemContainerView.superview else {
            return
        }
        
        // Hide animation
        if self.darkBackground {
            self.maskView.alpha = 1
        } else {
            self.maskView.alpha = 0
        }
        
        let moveY = targetView.bounds.height - self.itemContainerView.frame.origin.y
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        self.maskView.alpha = 0
                        self.itemContainerView.transform = CGAffineTransform(translationX: 0, y: moveY)
        }) { (result: Bool) -> Void in
            // Remove views
            self.itemContainerView.removeFromSuperview()
            self.maskView.removeFromSuperview()
            
            // Remove this instance
            for i in 0 ..< CustomActionSheet.actionSheets.count {
                if CustomActionSheet.actionSheets[i] == self {
                    CustomActionSheet.actionSheets.remove(at: i)
                    break
                }
            }
            
            self.closeBlock?()
        }
    }
    
    // MARK: - Private methods
    @objc private func maskViewWasTapped() {
        self.dismiss()
    }
    
    @objc private func buttonWasTapped(_ sender: AnyObject) {
        guard let items = self.items else {
            return
        }
        for item in items {
            guard
                let element = item.element,
                let gestureRecognizer = sender as? UITapGestureRecognizer else {
                    continue
            }
            if element == gestureRecognizer.view {
                item.onClick?(self)
            }
        }
    }
}
