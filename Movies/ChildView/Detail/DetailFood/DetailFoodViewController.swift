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
  @IBOutlet private weak var numberProductLabel: UILabel!
  @IBOutlet private weak var increaseButton: UIButton!
  @IBOutlet private weak var reduceButton: UIButton!
  @IBOutlet private weak var buyButton: UIButton!
  
  //variable
  private var quantity = 0
  var detailFood: FoodModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    guard let detailFood = detailFood else { return }
    configure(model: detailFood)
  }
  
  private func setupView() {
    totalLabel.text = "total".localized()
    quantityLabel.text = "\(quantity)"
    buyButton.setTitle("order_now".localized(), for: .normal)
    
    CAGradientLayer().gradientButton(btn: buyButton)
    self.enableEdgePanBackGesture()
  }
  
  private func configure(model: FoodModel) {
    if let pdfData = model.pdfData, let pdfImage = UIImage.convertDataToImage(from: pdfData) {
      foodImage.image = pdfImage
    } else {
      foodImage.image = UIImage(named: "placeholder")
    }
    titleLabel.text = model.title
    numberProductLabel.text = "\(model.total)"
    ratingLabel.text = "\(model.userScore)"
    descriptionLabel.text = model.describe
    priceLabel.text = "$ \(model.price)"
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
  
  @IBAction func buyTapped(_ sender: Any) {
    
  }
}
