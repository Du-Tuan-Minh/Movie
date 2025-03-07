//
//  HomeCell.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit

enum HomeCellType: CaseIterable {
  case compareTwoMovies
  case compareMovies
  case watchlist
  case history
  
  var image: UIImage {
    switch self {
    case .compareTwoMovies:
      return UIImage(resource: .compareTwo)
    case .compareMovies:
      return UIImage(resource: .compareMore)
    case .watchlist:
      return UIImage(resource: .watch)
    case .history:
      return UIImage(resource: .history)
    }
  }
  
  var title: String {
    switch self {
    case .compareTwoMovies:
      return "Compare Two Movies"
    case .compareMovies:
      return "Compare Movies"
    case .watchlist:
      return "Watchlist"
    case .history:
      return "History"
    }
  }
}

class HomeCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabelCell: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func configHomeCell(with image: UIImage, title: String) {
    imageCell.image = image
    titleLabelCell.text = title
  }
  
}
