//
//  LoginViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 24/4/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {
  
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
    setupText()
    setupColor()
  }
  
  private func setupText() {
    
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: logInButton)
  }
  
  private func confirmAuth() {
    if Auth.auth().currentUser != nil {
      movieViewController()
    }
  }
  
  private func loginApp() {
    guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
      showAlert(title: "Alert", message: "Opp! Please try again later", onAction: {})
      return
    }
    if !email.validateEmailId() {
      showAlert(title: "Alert", message: "Email address not found", onAction: {})
    } else {
      loginEmail()
    }
  }
  
  private func loginEmail() {
    Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { result, error in
      if let error = error {
        self.showAlert(title: "Error", message: "\(error.localizedDescription)", onAction: {})
      } else {
        self.movieViewController()
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
