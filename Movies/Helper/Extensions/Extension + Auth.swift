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
  
  func loginGoogle(completion: @escaping (Error?) -> Void = { _ in }) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google client ID not found".localized()])
      showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
      completion(error)
      return
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
      guard let self = self else {
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil".localized()])
        completion(error)
        return
      }
      
      if let error = error {
        showAlert(title: "Google Login Error".localized(), message: error.localizedDescription, onAction: {})
        completion(error)
        return
      }
      
      guard let user = result?.user, let idToken = user.idToken?.tokenString else {
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user details".localized()])
        showAlert(title: "Google Login Error".localized(), message: error.localizedDescription, onAction: {})
        completion(error)
        return
      }
      
      let accessToken = user.accessToken.tokenString
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
      
      Auth.auth().signIn(with: credential) { authResult, error in
        if let error = error {
          self.showAlert(title: "Firebase Login Error".localized(), message: error.localizedDescription, onAction: {})
          completion(error)
          return
        }
        
        // Kiểm tra user đã tồn tại trong Firestore
        FirebaseManager.shared.getUserRole { role in
          if role == nil, let firebaseUser = Auth.auth().currentUser {
            // User mới, lưu vào Firestore mà không cần mật khẩu
            let email = firebaseUser.email ?? "unknown@gmail.com"
            let username = firebaseUser.displayName ?? "User_\(firebaseUser.uid.prefix(8))"
            FirebaseManager.shared.registerGoogleUser(email: email, username: username, uid: firebaseUser.uid) { error in
              if let error = error {
                self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
                completion(error)
              } else {
                self.movieViewController()
                completion(nil)
              }
            }
          } else {
            // User đã tồn tại
            self.movieViewController()
            completion(nil)
          }
        }
      }
    }
  }
}
