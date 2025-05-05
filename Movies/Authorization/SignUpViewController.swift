//
//  SignUpViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 24/4/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignUpViewController: UIViewController {
  
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
  //}
  //
  ////MARK: setup view
  //extension SignUpViewController {
  private func setupView() {
    setupText()
    setupColor()
  }
  
  private func setupText() {
    
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: signUpButton)
  }
  
  private func showCreateAccount() {
    showAlert(title: "Create Account", message: "Would you like to create an account?") {
      self.registerNewAccount()
    }
  }
  
  private func registerNewAccount() {
    Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) { result, error in
      if let error = error {
        self.showAlert(title: "Error", message: "\(error.localizedDescription)", onAction: {})
      } else {
        result?.user.sendEmailVerification()
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  @IBAction func signUpTapped(_ sender: Any) {
    if let fullName = fullNameTextField.text, let emailAddress = emailAddressTextField.text, let password = passwordTextField.text, let reEnterPassword = reEnterPasswordTextField.text {
      if fullName == "" {
        showAlert(title: "Alert", message: "Please input full name", onAction: {})
      } else if !emailAddress.validateEmailId() {
        showAlert(title: "Alert", message: "Please enter valid email", onAction: {})
      } else {
        if password == reEnterPassword {
          showCreateAccount()
        } else {
          showAlert(title: "Alert", message: "Confirm password is error", onAction: {})
        }
      }
    } else {
      showAlert(title: "Alert", message: "Opp! Please try again later", onAction: {})
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
