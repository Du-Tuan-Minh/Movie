//
//  SignUpViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 24/4/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignUpViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var fullNameLabel: UILabel!
  @IBOutlet private weak var emailAddressLabel: UILabel!
  @IBOutlet private weak var passwordLabel: UILabel!
  @IBOutlet private weak var reEnterPasswordLabel: UILabel!
  @IBOutlet private weak var instructLabel: UILabel!
  @IBOutlet private weak var fullNameTextField: UITextField!
  @IBOutlet private weak var emailAddressTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  @IBOutlet private weak var reEnterPasswordTextField: UITextField!
  @IBOutlet private weak var forgotPasswordButton: UIButton!
  @IBOutlet private weak var signUpButton: UIButton!
  @IBOutlet private weak var logInButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
}

//MARK: setup view
extension SignUpViewController {
  private func setupView() {
    setupText()
    setupColor()
  }
  
  private func setupText() {
    titleLabel.text = "Sign Up"
    fullNameLabel.text = "Full Name"
    emailAddressLabel.text = "Email Address"
    passwordLabel.text = "Password"
    reEnterPasswordLabel.text = "Re-enter Password"
    instructLabel.text = "Please fill in all fields to create an account"
    signUpButton.setTitle("Sign Up", for: .normal)
    logInButton.setTitle("Already have an account? Log In", for: .normal)
    forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: signUpButton)
  }
  
  private func registerNewAccount(email: String, password: String, username: String) {
    FirebaseManager.shared.registerUser(email: email, password: password, username: username) { error in
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else {
        Auth.auth().currentUser?.sendEmailVerification { error in
          if let error = error {
            self.showAlert(title: "Error", message: "Failed to send verification email: \(error.localizedDescription)", onAction: {})
          } else {
            self.showAlert(title: "Success", message: "Account created! Please verify your email.", onAction: {
              self.navigationController?.popViewController(animated: true)
            })
          }
        }
      }
    }
  }
  
  @IBAction func signUpTapped(_ sender: Any) {
    guard let fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let email = emailAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          let password = passwordTextField.text,
          let reEnterPassword = reEnterPasswordTextField.text else {
      showAlert(title: "Error", message: "Please fill in all fields", onAction: {})
      return
    }
    
    // Validation
    if fullName.isEmpty {
      showAlert(title: "Error", message: "Please enter your full name", onAction: {})
      return
    }
    
    if !email.validateEmailId() {
      showAlert(title: "Error", message: "Please enter a valid email", onAction: {})
      return
    }
    
    if password != reEnterPassword {
      showAlert(title: "Error", message: "Passwords do not match", onAction: {})
      return
    }
    
    if password.count < 6 {
      showAlert(title: "Error", message: "Password must be at least 6 characters", onAction: {})
      return
    }

    showAlert(title: "Create Account", message: "Would you like to create an account?") {
      self.registerNewAccount(email: email, password: password, username: fullName)
    }
  }
  
  @IBAction func signInTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func forgotPasswordTapped(_ sender: Any) {
    pushViewController(view: ForgotPasswordViewController())
  }
  
  @IBAction func signUpGoogleTapped(_ sender: Any) {
    loginGoogle()
  }
}
