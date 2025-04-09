//
//  TypeFoodCell.swift
//  Movies
//
//  Created by DuTuanMinh on 9/4/25.
//

import UIKit

class TypeFoodCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var typeFoodButton: UIButton!
  
  func configure(with type: TypeFoodModel) {
    typeFoodButton.setTitle(type.title, for: .normal)
  }
}
