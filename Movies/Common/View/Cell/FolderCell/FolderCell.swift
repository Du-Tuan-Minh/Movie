//
//  FolderCell.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit

class FolderCell: UICollectionViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configueFolderCell(with title: String) {
    titleLabel.text = title
  }

  @IBAction func chooseStatusTapped(_ sender: Any) {
  }
}
