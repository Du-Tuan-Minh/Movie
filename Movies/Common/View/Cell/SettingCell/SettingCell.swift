//
//  SettingCell.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

enum SettingCellType: String, CaseIterable {
  case aboutApp
  case primaryPolicy
  case rating
  case feedBack
  case appLanguage
  
  var image: UIImage {
    switch self {
    case .aboutApp:
      return UIImage(resource: .aboutApp)
    case .primaryPolicy:
      return UIImage(resource: .lock)
    case .rating:
      return UIImage(resource: .starGray)
    case .feedBack:
      return UIImage(resource: .feedback)
    case .appLanguage:
      return UIImage(resource: .language)
    }
  }
  
  var title: String {
    switch self {
    case .aboutApp:
      return "aboutApp".localized()
    case .primaryPolicy:
      return "privacy_policy".localized()
    case .rating:
      return "rating".localized()
    case .feedBack:
      return "feedBack".localized()
    case .appLanguage:
      return "language".localized()
    }
  }
}

class SettingCell: UITableViewCell {
  
  //outlet
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  func configuareSettingCell(with image: UIImage, title: String) {
    imageCell?.image = image
    titleLabel.text = title
  }
}
