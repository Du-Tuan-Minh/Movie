//
//  SearchCell.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

class SearchCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabelCell: UILabel!
  @IBOutlet private weak var yearLabelCell: UILabel!
  @IBOutlet private weak var containView: UIView!
  
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
    if isStatus {
      containView.layer.borderColor = UIColor(resource: .lightBlue).cgColor
    } else {
      containView.layer.borderColor = UIColor.clear.cgColor
    }
  }
  
  func isReplaceCell(isStatus: Bool) {
    if isStatus {
      containView.layer.borderColor = UIColor.red.cgColor
    } else {
      containView.layer.borderColor = UIColor.clear.cgColor
    }
  }
}
