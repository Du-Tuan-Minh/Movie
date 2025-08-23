//
//  Extension + Gesture.swift
//  Movies
//
//  Created by DuTuanMinh on 12/4/25.
//

import UIKit

extension UIViewController {
  func enablePanBackGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    view.addGestureRecognizer(panGesture)
  }
  
  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    
    if translation.x > 80, gesture.state == .ended {
      if let navigationController = navigationController {
        navigationController.popViewController(animated: true)
      } else {
        dismiss(animated: true, completion: nil)
      }
    }
  }
  
  func hidenKeyboardWhenTapAround() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGestureRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
