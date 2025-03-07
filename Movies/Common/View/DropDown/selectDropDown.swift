//
//  selectDropDown.swift
//  Movies
//
//  Created by DuTuanMinh on 7/3/25.
//

import UIKit
import DropDown

class selectDropDown: DropDownCell {
  
  //outlet
  @IBOutlet private weak var deleteImage: UIImageView!
  @IBOutlet private weak var deleteLabel: UILabel!
  @IBOutlet private weak var replaceImage: UIImageView!
  @IBOutlet private weak var replaceLabel: UILabel!
  
    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func configSelectDropDown(delete: UIImage, deleteTitle: String, replace: UIImage, replaceTitle: String) {
    deleteImage.image = delete
    replaceImage.image = replace
    deleteLabel.text = deleteTitle
    replaceLabel.text = replaceTitle
  }
  
}
