//
//  Extension + PopUp.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit

extension UIViewController {
  func configurePopUp(blureView: UIView, contentView: UIView) {
    blureView.backgroundColor = .black.withAlphaComponent(0.5)
    blureView.alpha = 0
    contentView.alpha = 0
  }
  
  func showPopUp(blureView: UIView, contentView: UIView) {
    UIView.animate(withDuration: 0.3) {
      blureView.alpha = 1
      contentView.alpha = 1
    }
  }
  
  func hinderPopUp(blureView: UIView, contentView: UIView) {
    UIView.animate(withDuration: 0.3) {
      blureView.alpha = 0
      contentView.alpha = 0
      self.dismiss(animated: true)
      self.removeFromParent()
    }
  }
}
