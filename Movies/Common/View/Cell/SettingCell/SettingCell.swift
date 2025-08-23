//
//  SettingCell.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

enum SettingCellType: String, CaseIterable {
  case feedBack
  case appLanguage
  case logout
  
  var image: UIImage {
    switch self {
    case .feedBack:
      return UIImage(resource: .feedback)
    case .appLanguage:
      return UIImage(resource: .language)
    case .logout:
      return UIImage(resource: .logout)
    }
  }
  
  var title: String {
    switch self {
    case .feedBack:
      return "feedBack".localized()
    case .appLanguage:
      return "language".localized()
    case .logout:
      return "logout".localized()
    }
  }
}

class SettingCell: UITableViewCell {
  //outlet
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  static let reuseIdentifier: String = "SettingCell"
  
  func configuareSettingCell(with image: UIImage, title: String) {
    imageCell?.image = image
    titleLabel.text = title
  }
}
