//
//  SelectCell.swift
//  Movies
//
//  Created by DuTuanMinh on 20/3/25.
//

import DropDown
import UIKit

class SelectCell: DropDownCell {
  
  @IBOutlet private weak var movieImage: UIImageView!
  
  func configSelectDropDown(selectImage: UIImage?, selectTitle: String?) {
    if let selectImage = selectImage, let selectTitle = selectTitle {
      movieImage.image = selectImage
      optionLabel.text = selectTitle
    } else {
      movieImage.image = UIImage(systemName: "questionmark")
      optionLabel.text = "deleteTitle"
    }
  }
}
