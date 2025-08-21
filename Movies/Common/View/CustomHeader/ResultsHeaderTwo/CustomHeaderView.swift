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
        movieImage: UIImage.convertDataToImage(from: firstMovie.pdfData ?? Data()) ?? defaultImage,
        title: firstMovie.title,
        releaseYear: "\(firstMovie.releaseYear)"
      ),
      ResultsCompareHeaderView(
        movieImage: UIImage.convertDataToImage(from: secondMovie.pdfData ?? Data()) ?? defaultImage,
        title: secondMovie.title,
        releaseYear: "\(secondMovie.releaseYear)"
      )
    ]
  }
}

final class CustomHeaderView: UIView {
  
  //outlet
  @IBOutlet private weak var movieFirstImage: UIImageView!
  @IBOutlet private weak var chooseFirstButton: UIButton!
  @IBOutlet private weak var titleFirstLabel: UILabel!
  @IBOutlet private weak var releaseYearFirstLabel: UILabel!
  
  @IBOutlet private weak var movieSecondImage: UIImageView!
  @IBOutlet private weak var chooseSecondButton: UIButton!
  @IBOutlet private weak var titleSecondLabel: UILabel!
  @IBOutlet private weak var releaseYearSecondLabel: UILabel!
  
  var listMovie: [MovieModel]?
  var onMoviesSelected: (([MovieModel]) -> Void)?
  private var selectedMovies: Set<MovieModel> = []
  private var isFirstSelected = false
  private var isSecondSelected = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureView() {
    guard let view = self.loadViewFromNib(nibName: "CustomHeaderView") else{return}
    view.frame = self.bounds
    self.addSubview(view)
  }
  
  private func updateButton(_ button: UIButton, isSelected: Bool) {
    let image = isSelected ? UIImage(resource: .tickCircle) : UIImage(resource: .circle)
    button.setImage(image, for: .normal)
  }
  
  func configureHeaderView(with firstMovie: MovieModel, secondMovie: MovieModel) {
    let results = ResultsCompareHeaderView.compareMoviesHeader(firstMovie: firstMovie, secondMovie: secondMovie)
    guard results.count == 2 else { return }
    
    titleFirstLabel.text = results[0].title
    releaseYearFirstLabel.text = "(\(Date().getYear(date: firstMovie.releaseYear ?? Date())))"
    movieFirstImage.image = results[0].movieImage
    
    titleSecondLabel.text = results[1].title
    releaseYearSecondLabel.text = "(\(Date().getYear(date: secondMovie.releaseYear ?? Date())))"
    movieSecondImage.image = results[1].movieImage
    
    isFirstSelected = false
    isSecondSelected = false
    selectedMovies.removeAll()
    
    updateButton(chooseFirstButton, isSelected: isFirstSelected)
    updateButton(chooseSecondButton, isSelected: isSecondSelected)
  }
  
  @IBAction func movieFirstTapped(_ sender: Any) {
    guard let listMovie = self.listMovie, listMovie.count >= 2 else { return }
    isFirstSelected.toggle()
    updateButton(chooseFirstButton, isSelected: isFirstSelected)
    
    let movie = listMovie[0]
    if isFirstSelected {
      selectedMovies.insert(movie)
    } else {
      selectedMovies.remove(movie)
    }
    onMoviesSelected?(Array(selectedMovies))
  }
  
  @IBAction func movieSecondTapped(_ sender: Any) {
    guard let listMovie = self.listMovie, listMovie.count >= 2 else { return }
    isSecondSelected.toggle()
    updateButton(chooseSecondButton, isSelected: isSecondSelected)
    
    let movie = listMovie[1]
    if isSecondSelected {
      selectedMovies.insert(movie)
    } else {
      selectedMovies.remove(movie)
    }
    onMoviesSelected?(Array(selectedMovies))
  }
}
