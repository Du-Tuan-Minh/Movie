//
//  CustomHeaderMoreView.swift
//  Movies
//
//  Created by DuTuanMinh on 16/3/25.
//

import UIKit

class CustomHeaderMoreView: UIView {
  //outlet
  @IBOutlet private weak var statusChooseButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var dropDownButton: UIButton!
  
  //variable
  static let identifier = "CustomHeaderMoreView"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureView() {
    guard let view = self.loadViewFromNib(nibName: "CustomHeaderMoreView") else{return}
    view.frame = self.bounds
    self.addSubview(view)
  }
}
