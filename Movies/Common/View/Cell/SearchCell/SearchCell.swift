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
  
  static let identifier: String = "SearchCell"
  
  func configSearchCell(with model: MovieModel) {
    UIImage().convertURLtoImage(movie: model, movieImage: imageCell)
    titleLabelCell.text = model.title
    yearLabelCell.text = "(\(Date().getYear(date: model.releaseYear ?? Date())))"
  }
  
  func isChooseCell(isStatus: Bool) {
    if isStatus {
      containView.layer.borderColor = UIColor(resource: .lightBlue).cgColor
    } else {
      containView.layer.borderColor = UIColor.clear.cgColor
    }
  }
  
  func isReplaceCell() {
    containView.layer.borderColor = UIColor.red.cgColor
  }
}
