//
//  Extension + Auth.swift
//  Movies
//
//  Created by DuTuanMinh on 1/5/25.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import AuthenticationServices

extension String {
  func validateEmailId() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return applyPredicateOnRegex(regexStr: emailRegEx)
  }
  
  func applyPredicateOnRegex(regexStr: String) -> Bool{
    let trimmedString = self.trimmingCharacters(in: .whitespaces)
    let validateOtherString = NSPredicate(format: "SELF MATCHES %@", regexStr)
    let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
    return isValidateOtherString
  }
}


extension UIViewController {
  func movieViewController() {
    let tabbarVC = TabbarViewController()
    tabbarVC.modalPresentationStyle = .fullScreen
    tabbarVC.modalTransitionStyle = .flipHorizontal
    present(tabbarVC, animated: true)
  }
  
  func pushViewController(view: UIViewController) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      let vc = view
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  //Login Google
  func loginGoogle() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
      if let error = error {
        self.showAlert(title: "Google Login Error", message: error.localizedDescription, onAction: {})
        return
      }
      guard let user = result?.user,
            let idToken = user.idToken?.tokenString else {
        self.showAlert(title: "Google Login Error", message: "Failed to retrieve user details.", onAction: {})
        return
      }
      let accessToken = user.accessToken.tokenString
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
      Auth.auth().signIn(with: credential) { [weak self] authResult, error in
        guard let self = self else { return }
        
        if let error = error {
          self.showAlert(title: "Firebase Login Error", message: error.localizedDescription, onAction: {})
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let vc = TabbarViewController()
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
      }
    }
  }
}
