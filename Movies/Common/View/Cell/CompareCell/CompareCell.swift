//
//  CompareCell.swift
//  Movies
//
//  Created by DuTuanMinh on 2/3/25.
//

import UIKit

protocol CompareCellDelegate: AnyObject {
  func didTapSelectButton(in cell: CompareCell)
}

class CompareCell: UITableViewCell {
  
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var yearOfReleaseLabel: UILabel!
  @IBOutlet private weak var selectButton: UIButton!
  
  //variable
  weak var delegate: CompareCellDelegate?
  var btn: UIButton? {
    return selectButton
  }
  
  func configureCompareCell(with model: MovieModel) {
    titleLabel.text = model.title
    yearOfReleaseLabel.text = "(\(model.releaseYear))"
  }
  
  @IBAction func showDropDownTapped(_ sender: Any) {
    delegate?.didTapSelectButton(in: self)
  }
}
