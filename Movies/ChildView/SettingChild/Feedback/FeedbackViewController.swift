//
//  FeedbackViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/4/25.
//

import UIKit

class FeedbackViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var toLabel: UILabel!
  @IBOutlet private weak var fromLabel: UILabel!
  @IBOutlet private weak var subjectLabel: UILabel!
  @IBOutlet private weak var feedbackLabel: UILabel!
  @IBOutlet private weak var sendButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupText()
    setupButton()
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
  
  @IBAction func sendTapped(_ sender: Any) {
    
  }
}
