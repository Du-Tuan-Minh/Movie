//
//  FooterCell.swift
//  Movies
//
//  Created by DuTuanMinh on 5/4/25.
//

import UIKit

protocol FooterCellDelegate: AnyObject {
  func footerClick()
}

class FooterCell: UIView {
  
  //outlet
  @IBOutlet private weak var footerButton: UIButton!
  
  //varriable
  static let identifier: String = "FooterCell"
  weak var delegate: FooterCellDelegate?
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupButton()
  }
  
  private func setupButton() {
    CAGradientLayer().gradientButton(btn: footerButton)
  }
  
  @IBAction func footerTapped(_ sender: Any) {
    delegate?.footerClick()
  }
}
