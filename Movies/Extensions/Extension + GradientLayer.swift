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
  
  func gradientButton(btn: UIButton) {
    addGradient(to: btn, colors: [UIColor(resource: .lightBlue), UIColor(resource: .violet)], startPoint:  CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    btn.layer.masksToBounds = true
  }
}
