//
//  Extension + GradientLayer.swift
//  Movies
//
//  Created by DuTuanMinh on 6/3/25.
//
import UIKit

extension CAGradientLayer {
  func addGradient(to view: UIView, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = colors.map { $0.cgColor }
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
}
