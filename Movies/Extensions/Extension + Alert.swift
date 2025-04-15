//
//  Extension + Alert.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

extension UIViewController {
  func showAlert(title: String, message: String, onAction: @escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      onAction()
    }
    let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }
}
