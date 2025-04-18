//
//  TypeFoodCell.swift
//  Movies
//
//  Created by DuTuanMinh on 9/4/25.
//

import UIKit

class TypeFoodCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var typeFoodLabel: UILabel!
  
  func configure(with type: String) {
    typeFoodLabel.text = type
  }
}
