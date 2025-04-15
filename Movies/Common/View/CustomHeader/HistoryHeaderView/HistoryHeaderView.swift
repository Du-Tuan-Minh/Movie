//
//  HistoryHeaderView.swift
//  Movies
//
//  Created by DuTuanMinh on 4/4/25.
//

import UIKit

class HistoryHeaderView: UICollectionReusableView {
  
  //outlet
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var chooseButton: UIButton!
  
  //variable
  weak var delegate: ChooseButtonSessionDelegate?
  var isToggle: Bool = false {
    didSet {
      chooseButton.setImage(isToggle ? UIImage(resource: .tickCircle) : UIImage(resource: .circle), for: .normal)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func configureHistoryHeaderView(with date: String) {
    dateLabel.text = date
  }
  
  @IBAction func chooseTapped(_ sender: Any) {
    isToggle.toggle()
    delegate?.chooseMovie(view: self)
  }
}
