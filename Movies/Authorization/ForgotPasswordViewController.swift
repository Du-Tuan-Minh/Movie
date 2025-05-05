//
//  ForgotPasswordViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 24/4/25.
//

import UIKit
import FirebaseAuth

enum ForgotPasswordMode {
  case forgot
  case reset
}

class ForgotPasswordViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var emailAddressLabel: UILabel!
  @IBOutlet private weak var confirmPasswordLabel: UILabel!
  @IBOutlet private weak var emailAddressTextField: UITextField!
  @IBOutlet private weak var confirmPassWordTextField: UITextField!
  @IBOutlet private weak var nextButton: UIButton!
  
  //variable
  var mode: ForgotPasswordMode = .forgot
  private var isEmailValid: Bool = true {
    didSet {
      if isEmailValid {
        confirmPasswordLabel.isHidden = true
        confirmPassWordTextField.isHidden = true
        nextButton.setTitle("Get code", for: .normal)
      } else {
        confirmPasswordLabel.isHidden = false
        confirmPassWordTextField.isHidden = false
        nextButton.setTitle("Comfirm", for: .normal)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    isEmailValid = true
  }
  
  private func setupView() {
    setupText()
    setupColor()
  }
  
  private func setupText() {
    if mode == .forgot {
      titleLabel.text = "Forgot password"
    } else if mode == .reset {
      titleLabel.text = "Reset password"
    }
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: nextButton)
  }
  
  private func updatePassword() {
    guard let email = emailAddressTextField.text, email.validateEmailId() else {
      showAlert(title: "Alert", message: "Please enter a valid email address.", onAction: {})
      return
    }
    if isEmailValid {
      Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        } else {
          showAlert( title: "Email Sent", message: "A password reset email has been sent to \(email). Please check your inbox.", onAction: {})
          self.isEmailValid = false
        }
      }
    } else {
      guard let confirmPassword = confirmPassWordTextField.text else {
        showAlert(title: "Alert", message: "Please enter your new password.", onAction: {})
        return
      }
      Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: confirmPassword) { authResult, error in
        if let error = error {
          self.showAlert(title: "Error", message: "Unable to log in with the new password. Please try again.", onAction: {})
        } else {
          self.movieViewController()
        }
      }
    }
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    updatePassword()
  }
}
