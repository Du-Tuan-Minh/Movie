//
//  FoodCell.swift
//  Movies
//
//  Created by DuTuanMinh on 26/3/25.
//

import UIKit

class FoodCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var foodImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var priceLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func configureFoodCell(with food: FoodModel) {
    guard let foodData = food.pdfData else { return }
    foodImage.image = UIImage().convertDateToImage(data: foodData)
    titleLabel.text = food.title
    priceLabel.text = "\(food.price) $"
  }
}
