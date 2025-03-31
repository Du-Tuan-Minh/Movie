//
//  SettingCell.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

enum SettingCellType: String, CaseIterable {
  case aboutApp = "About App"
  case primaryPolicy = "Privacy & Policy"
  case rating = "Rating"
  case feedBack = "FeedBack"
  
  var image: UIImage {
    switch self {
    case .aboutApp:
      return UIImage(systemName: "info.circle")!
    case .primaryPolicy:
      return UIImage(systemName: "lock.shield")!
    case .rating:
      return UIImage(systemName: "star")!
    case .feedBack:
      return UIImage(systemName: "envelope")!
    }
  }
}

class SettingCell: UITableViewCell {
  
  @IBOutlet private weak var imageCell: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!

  func configuareSettingCell(with image: UIImage, title: String) {
    imageCell?.image = image
    titleLabel.text = title
  }
}
