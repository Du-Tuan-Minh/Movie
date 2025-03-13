//
//  CustomHeaderView.swift
//  Movies
//
//  Created by DuTuanMinh on 9/3/25.
//

import UIKit

struct ResultsCompareHeaderView {
  var movieImage: UIImage
  var title: String
  var releaseYear: String
}

extension ResultsCompareHeaderView {
  static func compareMoviesHeader(firstMovie: MovieModel, secondMovie: MovieModel) -> [ResultsCompareHeaderView] {
    let defaultImage = UIImage(systemName: "doc.fill") ?? UIImage()
    return [
      ResultsCompareHeaderView(
        movieImage: UIImage.convertPDFToImage(from: firstMovie.pdfData ?? Data()) ?? defaultImage,
        title: firstMovie.title,
        releaseYear: "\(firstMovie.releaseYear)"
      ),
      ResultsCompareHeaderView(
        movieImage: UIImage.convertPDFToImage(from: secondMovie.pdfData ?? Data()) ?? defaultImage,
        title: secondMovie.title,
        releaseYear: "\(secondMovie.releaseYear)"
      )
    ]
  }
}

final class CustomHeaderView: UIView {
  
  //outlet
  @IBOutlet weak var movieFirstImage: UIImageView!
  @IBOutlet weak var chooseFirstButton: UIButton!
  @IBOutlet weak var titleFirstLabel: UILabel!
  @IBOutlet weak var releaseYearFirstLabel: UILabel!
  
  @IBOutlet weak var movieSecondImage: UIImageView!
  @IBOutlet weak var chooseSecondButton: UIButton!
  @IBOutlet weak var titleSecondLabel: UILabel!
  @IBOutlet weak var releaseYearSecondLabel: UILabel!
  
  var listMovie: [MovieModel]?
  var saveMovie: [MovieModel] = []
  var isChoose: Bool = false
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private func setupView(button: UIButton) {
    if isChoose {
      button.setImage(UIImage(resource: .tickCircle), for: .normal)
    } else {
      button.setImage(UIImage(resource: .circle), for: .normal)
    }
  }
  
  private func configureView() {
    guard let view = self.loadViewFromNib(nibName: "CustomHeaderView") else{return}
    view.frame = self.bounds
    self.addSubview(view)
  }
  
  func configureHeaderView(with firstMovie: MovieModel, secondMovie: MovieModel) {
    let results = ResultsCompareHeaderView.compareMoviesHeader(firstMovie: firstMovie, secondMovie: secondMovie)
    guard results.count >= 2 else { return }
    
    let resultItemFirst = results[0]
    let resultItemSecond = results[1]
    
    
    movieFirstImage.image = resultItemFirst.movieImage
    titleFirstLabel.text = resultItemFirst.title
    releaseYearFirstLabel.text = resultItemFirst.releaseYear
    
    movieSecondImage.image = resultItemSecond.movieImage
    titleSecondLabel.text = resultItemSecond.title
    releaseYearSecondLabel.text = resultItemSecond.releaseYear
  }
  
  @IBAction func movieFirstTapped(_ sender: Any) {
    isChoose.toggle()
    setupView(button: chooseFirstButton)
    guard let listMovie = self.listMovie, listMovie.count >= 2 else { return }
    saveMovie.append(listMovie[0])
  }
  
  
  @IBAction func movieSecondTapped(_ sender: Any) {
    isChoose.toggle()
    setupView(button: chooseSecondButton)
    guard let listMovie = self.listMovie, listMovie.count >= 2 else { return }
    saveMovie.append(listMovie[1])
  }
  
}
