//
//  BaseViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 20/8/25.
//

import UIKit

class BaseViewController: UIViewController {
  
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    self.hidenKeyboardWhenTapAround()
    self.enablePanBackGesture()
  }
  
  func showLoadingIndicator() {
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
  }
  
  func hideLoadingIndicator() {
    activityIndicator.stopAnimating()
    activityIndicator.removeFromSuperview()
  }
}
