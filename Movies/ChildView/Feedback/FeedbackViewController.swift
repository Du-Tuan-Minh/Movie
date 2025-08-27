//
//  FeedbackViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/4/25.
//

import UIKit
import MessageUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FeedbackViewController: BaseViewController, MFMailComposeViewControllerDelegate {
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var toLabel: UILabel!
  @IBOutlet private weak var fromLabel: UILabel!
  @IBOutlet private weak var subjectTextField: UITextField!
  @IBOutlet private weak var feedbackTextView: UITextView!
  @IBOutlet private weak var sendButton: UIButton!
  
  private let recipientEmail = "dutuanminh2812202@gmail.com"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupText()
    setupButton()
    loadUserInfo()
  }
  
  private func setupText() {
    titleLabel.text = "feedback".localized()
    toLabel.text = "to".localized()
    fromLabel.text = "from".localized()
    titleLabel.text = "feedback".localized()
    sendButton.setTitle("send".localized(), for: .normal)
  }
  
  private func setupButton() {
    CAGradientLayer().gradientButton(btn: sendButton)
  }
  
  private func loadUserInfo() {
    guard let userId = Auth.auth().currentUser?.uid else {
      fromLabel.text = "From: Not logged in"
      showAlert(title: "Error", message: "You must be logged in to send feedback", onAction: {})
      return
    }
    
    FirebaseManager.shared.fetchUsername(for: userId) { [weak self] username, error in
      guard let self = self else { return }
      if let error = error {
        self.fromLabel.text = "From: Error"
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let username = username {
        self.fromLabel.text = "From: \(username) (\(Auth.auth().currentUser?.email ?? "No email"))"
      }
    }
  }
  
  @IBAction func sendTapped(_ sender: Any) {
    guard MFMailComposeViewController.canSendMail() else {
      showAlert(title: "Error", message: "Mail services are not available. Please configure an email account.", onAction: {})
      return
    }
    
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to send feedback", onAction: {})
      return
    }
    
    let subject = subjectTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let feedback = feedbackTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    
    if subject.isEmpty || feedback.isEmpty {
      showAlert(title: "Error", message: "Please enter both subject and feedback", onAction: {})
      return
    }
    
    FirebaseManager.shared.fetchUsername(for: userId) { [weak self] username, error in
      guard let self = self else { return }
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        return
      }
      
      let mailVC = MFMailComposeViewController()
      mailVC.mailComposeDelegate = self
      mailVC.setToRecipients([self.recipientEmail])
      mailVC.setSubject(subject)
      mailVC.setMessageBody("From: \(username ?? "Unknown User") (\(Auth.auth().currentUser?.email ?? "No email"))\n\nFeedback:\n\(feedback)", isHTML: false)
      
      self.present(mailVC, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if let error = error {
      showAlert(title: "Error", message: error.localizedDescription, onAction: {})
    } else {
      switch result {
      case .sent:
        showAlert(title: "Success", message: "Feedback sent successfully", onAction: {})
      case .saved:
        showAlert(title: "Saved", message: "Feedback saved as draft", onAction: {})
      case .failed:
        showAlert(title: "Error", message: "Failed to send feedback", onAction: {})
      case .cancelled:
        break
      @unknown default:
        break
      }
    }
    controller.dismiss(animated: true, completion: nil)
  }
}
