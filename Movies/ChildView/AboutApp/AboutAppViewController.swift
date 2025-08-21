//
//  AboutAppViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/4/25.
//

import UIKit

class AboutAppViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var iconAppImage: UIImageView!
  @IBOutlet private weak var titleButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    titleButton.setTitle("aboutApp".localized(), for: .normal)
    iconAppImage.layer.cornerRadius = iconAppImage.frame.width / 2
  }
  
  @IBAction func backTapped(_ sender: Any) {
    dismiss(animated: true)
  }
}
