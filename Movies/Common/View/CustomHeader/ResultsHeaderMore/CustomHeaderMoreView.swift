//
//  CustomHeaderMoreView.swift
//  Movies
//
//  Created by DuTuanMinh on 16/3/25.
//

import UIKit

protocol CustomHeaderMoreViewDelegate: AnyObject {
  func chooseMovie(view: UIView)
}

class CustomHeaderMoreView: UIView {
  
  //outlet
  @IBOutlet private weak var statusChooseButton: UIButton!
  @IBOutlet private weak var userScore: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var dropDownButton: UIButton!
  
  //variable
  static let identifier = "CustomHeaderMoreView"
  weak var delegate: CustomHeaderMoreViewDelegate?
  var isChoose: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func chooseMovieTapped(_ sender: Any) {
    isChoose.toggle()
    statusChooseButton.setImage(isChoose ? UIImage(resource: .tickCircle) : UIImage(resource: .circle), for: .normal)
    delegate?.chooseMovie(view: self)
  }
  
  private func setupView() {
    guard let view = self.loadViewFromNib(nibName: CustomHeaderMoreView.identifier) else{return}
    view.frame = self.bounds
    self.addSubview(view)
  }
  
  func configureCustomHeaderMoreView(with model: MovieModel, at section: Int) {
    userScore.text = "\(model.userScore)"
    titleLabel.text = model.title
    releaseYearLabel.text = "(\(model.releaseYear))"
    userScore.textColor = section.isMultiple(of: 2) ?  UIColor(resource: .lightBlue) : UIColor(resource: .violet)
  }
}
