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
    if let pdfURL = model.imageURL {
      FirebaseManager.shared.storage.child(pdfURL).getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
        guard let self = self, let data = data, error == nil, let image = UIImage.convertDataToImage(from: data) else {
          self?.imageCell.image = UIImage(named: "placeholder")
          return
        }
        self.imageCell.image = image
      }
    } else {
      imageCell.image = UIImage(named: "placeholder")
    }
    
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
