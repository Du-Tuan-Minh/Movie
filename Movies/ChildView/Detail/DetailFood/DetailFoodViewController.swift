//
//  DetailFoodViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 13/4/25.
//

import UIKit

class DetailFoodViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var foodImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var ratingLabel: UILabel!
  @IBOutlet private weak var priceLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var quantityLabel: UILabel!
  @IBOutlet private weak var totalLabel: UILabel!
  @IBOutlet private weak var increaseButton: UIButton!
  @IBOutlet private weak var reduceButton: UIButton!
  @IBOutlet private weak var buyButton: UIButton!
  
  //variable
  var quantity = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    totalLabel.text = "total".localized()
    quantityLabel.text = "\(quantity)"
    buyButton.setTitle("order_now".localized(), for: .normal)
    
    CAGradientLayer().gradientButton(btn: buyButton)
    self.enableEdgePanBackGesture()
  }
  
  func configure(with item: TypeFoodModel) {
    titleLabel.text = item.title
  }
  
  @IBAction func increaseTapped(_ sender: Any) {
    quantity += 1
    quantityLabel.text = "\(quantity)"
  }
  
  @IBAction func reduceTapped(_ sender: Any) {
    if quantity > 0 {
      quantity -= 1
    } else {
      quantity = 0
    }
    quantityLabel.text = "\(quantity)"
  }
}
