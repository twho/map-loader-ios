//
//  ResManager.swift
//  LocationAudioMessage
//
//  Created by Ho, Tsung Wei on 7/17/18.
//  Copyright © 2018 Michael Ho. All rights reserved.
//

import UIKit

open class ResManager {
    
    /**
     Get annotation view foreground image
     
     - Parameter annotImage: the built-in resources of foreground annotation image
     
     Returns a UIImage from built-in resource
     */
    static func getAnnotImage(annotImage: StyledAnnotationView.AnnotationImage) -> UIImage {
        switch annotImage {
        case .error: return UIImage(named: "ic_error")!
        case .police: return UIImage(named: "ic_police")!
        case .hazard: return UIImage(named: "ic_hazard")!
        case .construction: return UIImage(named: "ic_constr")!
        case .crash: return UIImage(named: "ic_crash")!
        case .multiUser: return UIImage(named: "ic_public")!
        case .personal: return UIImage(named: "ic_personal")!
        case .gas: return UIImage(named: "ic_gas")!
        case .charging: return UIImage(named: "ic_charging")!
        }
    }
    
    /**
     Get annotation view background image
     
     - Parameter annotImage: the built-in resources of background annotation image
     
     Returns a UIImage from built-in resource
     */
    static func getBgImage(annotImage: StyledAnnotationView.BackgroundImage) -> UIImage {
        switch annotImage {
        case .bubble: return UIImage(named: "ic_annot1")!
        case .square: return UIImage(named: "ic_annot2")!
        case .circle: return UIImage(named: "ic_annot3")!
        case .heart: return UIImage(named: "ic_annot4")!
        case .flag: return UIImage(named: "ic_annot5")!
        }
    }
}
