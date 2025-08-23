//
//  Extension + Alert.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, onAction: @escaping () -> Void, additionalActions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            onAction()
        }
        alert.addAction(okAction)

        for action in additionalActions {
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
