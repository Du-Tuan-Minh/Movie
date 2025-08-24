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
    // Load image from URL
    let placeholderImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo") ?? UIImage()
    if let imageURL = model.imageURL, let url = URL(string: imageURL) {
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self = self, let data = data, error == nil else {
          DispatchQueue.main.async {
            self?.imageCell.image = placeholderImage
          }
          return
        }
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self.imageCell.image = image
          }
        } else {
          DispatchQueue.main.async {
            self.imageCell.image = placeholderImage
          }
        }
      }.resume()
    } else {
      imageCell.image = placeholderImage
    }
    
    // Configure other UI elements
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
