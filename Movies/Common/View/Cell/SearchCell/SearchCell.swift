//
//  SearchCell.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

class SearchCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabelCell: UILabel!
  @IBOutlet private weak var yearLabelCell: UILabel!
  @IBOutlet private weak var ContentView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func configSearchCell(with model: MovieModel) {
    if let pdfData = model.pdfData, let pdfImage = UIImage.convertPDFToImage(from: pdfData) {
      imageCell.image = pdfImage
    } else {
      imageCell.image = UIImage(named: "placeholder")
    }
    titleLabelCell.text = model.title
    yearLabelCell.text = "(\(model.releaseYear))"
  }
  
  func isChooseCell(isStatus: Bool) {
    ContentView.layer.borderWidth = 3
    ContentView.layer.masksToBounds = true
    if isStatus {
      ContentView.layer.borderColor = UIColor(resource: .lightBlue).cgColor
    } else {
      ContentView.layer.borderColor = UIColor.clear.cgColor
    }
  }
}
