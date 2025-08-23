//
//  LoginViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 24/4/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var passwordLabel: UILabel!
  @IBOutlet private weak var instructLabel: UILabel!
  @IBOutlet private weak var emailTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var forgotPasswordButton: UIButton!
  @IBOutlet private weak var logInButton: UIButton!
  @IBOutlet private weak var signUpButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    confirmAuth()
  }
}

//MARK: setup View
extension LoginViewController {
  private func setupView() {
    setupColor()
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: logInButton)
  }
  
  private func checkUserRole() {
    FirebaseManager.shared.getUserRole { role in
      if role != nil {
        self.movieViewController()
      } else {
        self.showAlert(title: "Error", message: "Please sign up again.", onAction: {
          try? Auth.auth().signOut()
        })
      }
    }
  }
  
  private func confirmAuth() {
    if Auth.auth().currentUser != nil {
      checkUserRole()
    }
  }
  
  private func loginApp() {
    guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      showAlert(title: "Error", message: "Please fill in all fields", onAction: {})
      return
    }
    
    if email.isEmpty {
      showAlert(title: "Error", message: "Please enter your email address", onAction: {})
      return
    }
    
    if !email.validateEmailId() {
      showAlert(title: "Error", message: "Please enter a valid email address", onAction: {})
      return
    }
    
    if password.isEmpty {
      showAlert(title: "Error", message: "Please enter your password", onAction: {})
      return
    }
    
    if password.count < 6 {
      showAlert(title: "Error", message: "Password must be at least 6 characters", onAction: {})
      return
    }
    
    showLoadingIndicator()
    
    FirebaseManager.shared.signIn(email: email, password: password) { [weak self] error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else {
        checkUserRole()
      }
    }
  }
  
  @IBAction func signUpTapped(_ sender: Any) {
    self.pushViewController(view: SignUpViewController())
  }
  
  @IBAction func logInTapped(_ sender: Any) {
    loginApp()
  }
  
  @IBAction func forgotPasswordTapped(_ sender: Any) {
    self.pushViewController(view: ForgotPasswordViewController())
  }
  
  @IBAction func loginGoogleTapped(_ sender: Any) {
    loginGoogle()
  }
}
