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

class ForgotPasswordViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var emailAddressLabel: UILabel!
  @IBOutlet private weak var confirmPasswordLabel: UILabel!
  @IBOutlet private weak var emailAddressTextField: UITextField!
  @IBOutlet private weak var confirmPassWordTextField: UITextField!
  @IBOutlet private weak var nextButton: UIButton!
  
  //variable
  var mode: ForgotPasswordMode = .forgot
  var oobCode: String?
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
    emailAddressLabel.text = "Email Address"
    confirmPasswordLabel.text = "New Password"
    if mode == .forgot {
      titleLabel.text = "Forgot Password"
    } else if mode == .reset {
      titleLabel.text = "Reset Password"
    }
  }
  
  private func setupColor() {
    CAGradientLayer().gradientButton(btn: nextButton)
  }
  
  private func updatePassword() {
    guard let email = emailAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      showAlert(title: "Error", message: "Please enter your email address", onAction: {})
      return
    }
    
    if !email.validateEmailId() {
      showAlert(title: "Error", message: "Please enter a valid email address", onAction: {})
      return
    }
    
    showLoadingIndicator()
    if isEmailValid {
      // Mode: Forgot - Gửi email reset
      FirebaseManager.shared.sendPasswordResetEmail(email: email) { [weak self] error in
        guard let self = self else { return }
        self.hideLoadingIndicator()
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        } else {
          self.showAlert(title: "Email Sent", message: "A password reset email has been sent to \(email). Please check your inbox.", onAction: {
            self.isEmailValid = false
          })
        }
      }
    } else {
      // Mode: Reset - Xác nhận mật khẩu mới
      guard let newPassword = confirmPassWordTextField.text, !newPassword.isEmpty else {
        self.hideLoadingIndicator()
        showAlert(title: "Error", message: "Please enter a new password", onAction: {})
        return
      }
      
      if newPassword.count < 6 {
        self.hideLoadingIndicator()
        showAlert(title: "Error", message: "Password must be at least 6 characters", onAction: {})
        return
      }
      
      guard let oobCode = oobCode else {
        self.hideLoadingIndicator()
        showAlert(title: "Error", message: "Invalid reset code. Please request a new reset email.", onAction: {})
        return
      }
      
      FirebaseManager.shared.confirmPasswordReset(oobCode: oobCode, newPassword: newPassword) { [weak self] error in
        guard let self = self else { return }
        self.hideLoadingIndicator()
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        } else {
          self.showAlert(title: "Success", message: "Password reset successfully!", onAction: {
            self.navigationController?.popViewController(animated: true)
          })
        }
      }
    }
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    updatePassword()
  }
}
