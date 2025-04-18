//
//  OnboardingCell.swift
//  Movies
//
//  Created by DuTuanMinh on 12/4/25.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
  
  //outlet
  @IBOutlet private weak var slideImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  //variable
  static let reuseIdentifier = "OnboardingCell"
  
  func configureOnboardingCell(slide: OnboaringSlide) {
    slideImage.image = slide.image
    titleLabel.text = slide.title
    descriptionLabel.text = slide.description
  }
}
