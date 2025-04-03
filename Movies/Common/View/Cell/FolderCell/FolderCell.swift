//
//  FolderCell.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit

class FolderCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  
  //variable
  var didTapSelect: (() -> Void)?
  
  func configueFolderCell(with title: String) {
    titleLabel.text = title
  }
  
  @IBAction func chooseStatusTapped(_ sender: Any) {
    didTapSelect?()
  }
}
