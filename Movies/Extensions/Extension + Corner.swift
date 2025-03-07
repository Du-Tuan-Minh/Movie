//
//  Extension + Corner.swift
//  Movies
//
//  Created by DuTuanMinh on 8/3/25.
//

import Foundation
import UIKit

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
}

extension UIView {
//    func border(width: CGFloat? = nil, color: CGColor? = nil, radius: CGFloat? = nil, clipsToBounds: Bool? = nil, masksToBounds: Bool? = nil) {
//        if let borderWidth: CGFloat = width {
//            self.layer.borderWidth = borderWidth
//        }
//        if let borderColor: CGColor = color {
//            self.layer.borderColor = borderColor
//        }
//        if let cornerRadius: CGFloat = radius {
//            self.layer.cornerRadius = cornerRadius
//        }
//        if let clip: Bool = clipsToBounds {
//            self.clipsToBounds = clip
//        }
//        if let mask: Bool = masksToBounds {
//            self.layer.masksToBounds = mask
//        }
//    }
//
    func setCornerRadius(_ radius: CGFloat, corners: [Corner]) {
        var maskedCorners: CACornerMask = []
        
        // Map the corners from the enum to the appropriate CACornerMask values
        for corner in corners {
            switch corner {
            case .topLeft:
                maskedCorners.insert(.layerMinXMinYCorner)
            case .topRight:
                maskedCorners.insert(.layerMaxXMinYCorner)
            case .bottomLeft:
                maskedCorners.insert(.layerMinXMaxYCorner)
            case .bottomRight:
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
        }
        
        // Apply the corner radius and masked corners
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = maskedCorners
    }
    
    func shadow(color: CGColor? = nil, opacity: Float? = nil, offset: CGSize? = nil, radius: CGFloat? = nil) {
        //reset shadow
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.00
        clipsToBounds = false
        
        
        //change shadow
        if let shadowColor: CGColor = color {
            self.layer.shadowColor = shadowColor
        }
        if let shadowOpacity: Float = opacity {
            self.layer.shadowOpacity = shadowOpacity
        }
        if let shadowOffset: CGSize = offset {
            self.layer.shadowOffset = shadowOffset
        }
        if let shadowRadius: CGFloat = radius {
            self.layer.shadowRadius = shadowRadius
        }
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func addGradient(_ colors: [UIColor], locations: [NSNumber], frame: CGRect = .zero) {
        
        // Create a new gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Set the colors and locations for the gradient layer
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.locations = locations
        
        // Set the start and end points for the gradient layer
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        // Set the frame to the layer
        gradientLayer.frame = frame
        
        // Add the gradient layer as a sublayer to the background view
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
