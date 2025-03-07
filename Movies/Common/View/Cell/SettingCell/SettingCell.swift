//
//  SettingCell.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

class SettingCell: UITableViewCell {

  @IBOutlet private weak var imageCell: NSLayoutConstraint!
  @IBOutlet private weak var titleLabel: NSLayoutConstraint!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
