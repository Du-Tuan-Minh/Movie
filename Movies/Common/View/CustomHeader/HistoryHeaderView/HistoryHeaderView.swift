//
//  HistoryHeaderView.swift
//  Movies
//
//  Created by DuTuanMinh on 4/4/25.
//

import UIKit

class HistoryHeaderView: UICollectionReusableView {
  
  @IBOutlet weak var dateLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

  }
  
  func configure(with date: String) {
          //dateLabel.text = date
      }
}
