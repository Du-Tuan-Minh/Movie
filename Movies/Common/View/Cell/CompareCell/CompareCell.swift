//
//  CompareCell.swift
//  Movies
//
//  Created by DuTuanMinh on 2/3/25.
//

import UIKit

class CompareCell: UITableViewCell {
  
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var yearOfReleaseLabel: UILabel!
  @IBOutlet private weak var selectButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func configureCompareCell(with model: MovieModel) {
    titleLabel.text = model.title
    yearOfReleaseLabel.text = "(\(model.releaseYear))"
    print(" model.title\( model.title)")
  }
  
  @IBAction func showDropDownTapped(_ sender: Any) {
    // CompareMoviesViewController().menu.show()
  }
}
