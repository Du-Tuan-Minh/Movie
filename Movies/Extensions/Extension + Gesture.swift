//
//  Extension + Gesture.swift
//  Movies
//
//  Created by DuTuanMinh on 12/4/25.
//

import UIKit

extension UIViewController {
  func enableEdgePanBackGesture() {
    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
    edgePan.edges = .left
    view.addGestureRecognizer(edgePan)
  }
  
  @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
    if gesture.state == .recognized {
      if let navigationController = navigationController {
        navigationController.popViewController(animated: true)
      } else {
        dismiss(animated: true, completion: nil)
      }
    }
  }
}
