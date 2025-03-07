//
//  SearchCell.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

class SearchCell: UICollectionViewCell {

  @IBOutlet weak var imageCell: UIImageView!
  @IBOutlet weak var titleLabelCell: UILabel!
  @IBOutlet weak var yearLabelCell: UILabel!
  
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
}
