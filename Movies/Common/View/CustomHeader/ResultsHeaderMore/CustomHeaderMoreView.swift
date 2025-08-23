//
//  CustomHeaderMoreView.swift
//  Movies
//
//  Created by DuTuanMinh on 16/3/25.
//

import UIKit

protocol ChooseButtonSessionDelegate: AnyObject {
  func chooseMovie(view: UIView)
}

class CustomHeaderMoreView: UIView {
  //outlet
  @IBOutlet private weak var statusChooseButton: UIButton!
  @IBOutlet private weak var userScore: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var dropDownButton: UIButton!
  @IBOutlet private weak var arrowButton: UIButton!
  
  //variable
  static let identifier = "CustomHeaderMoreView"
  weak var delegate: ChooseButtonSessionDelegate?
  var isChoose: Bool = false {
    didSet {
      statusChooseButton.setImage(isChoose ? UIImage(resource: .tickCircle) : UIImage(resource: .circle), for: .normal)
    }
  }
  
  var isStatusArrow: Bool = false {
    didSet {
      arrowButton.setImage(isStatusArrow ? UIImage(resource: .arrowUp) : UIImage(resource: .arrowDown), for: .normal)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    guard let view = self.loadViewFromNib(nibName: CustomHeaderMoreView.identifier) else { return }
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    isStatusArrow = false
  }
  
  @IBAction func chooseMovieTapped(_ sender: Any) {
    isChoose.toggle()
    delegate?.chooseMovie(view: self)
  }
  
  func configureCustomHeaderMoreView(with model: MovieModel, at section: Int) {
    userScore.text = "\(model.userScore)"
    titleLabel.text = model.title
    releaseYearLabel.text = "(\(Date().getYear(date: model.releaseYear ?? Date())))"
    userScore.textColor = section.isMultiple(of: 2) ?  UIColor(resource: .lightBlue) : UIColor(resource: .violet)
  }
}
