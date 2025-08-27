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
  static func compareMoviesHeader(firstMovie: MovieModel, secondMovie: MovieModel, completion: @escaping ([ResultsCompareHeaderView]) -> Void) {
    let defaultImage = UIImage(systemName: "doc.fill") ?? UIImage()
    var results: [ResultsCompareHeaderView] = []
    let dispatchGroup = DispatchGroup()
    
    // Load first movie image
    if let imageURL = firstMovie.imageURL, let url = URL(string: imageURL) {
      dispatchGroup.enter()
      URLSession.shared.dataTask(with: url) { data, response, error in
        let image = data != nil ? UIImage(data: data!) ?? defaultImage : defaultImage
        DispatchQueue.main.async {
          results.append(ResultsCompareHeaderView(
            movieImage: image,
            title: firstMovie.title,
            releaseYear: "\(Date().getYear(date: firstMovie.releaseYear ?? Date()))"
          ))
          dispatchGroup.leave()
        }
      }.resume()
    } else {
      results.append(ResultsCompareHeaderView(
        movieImage: defaultImage,
        title: firstMovie.title,
        releaseYear: "\(Date().getYear(date: firstMovie.releaseYear ?? Date()))"
      ))
    }
    
    // Load second movie image
    if let imageURL = secondMovie.imageURL, let url = URL(string: imageURL) {
      dispatchGroup.enter()
      URLSession.shared.dataTask(with: url) { data, response, error in
        let image = data != nil ? UIImage(data: data!) ?? defaultImage : defaultImage
        DispatchQueue.main.async {
          results.append(ResultsCompareHeaderView(
            movieImage: image,
            title: secondMovie.title,
            releaseYear: "\(Date().getYear(date: secondMovie.releaseYear ?? Date()))"
          ))
          dispatchGroup.leave()
        }
      }.resume()
    } else {
      results.append(ResultsCompareHeaderView(
        movieImage: defaultImage,
        title: secondMovie.title,
        releaseYear: "\(Date().getYear(date: secondMovie.releaseYear ?? Date()))"
      ))
    }
    
    dispatchGroup.notify(queue: .main) {
      completion(results)
    }
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
    configureView()
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
    ResultsCompareHeaderView.compareMoviesHeader(firstMovie: firstMovie, secondMovie: secondMovie) { [weak self] results in
      guard let self = self, results.count == 2 else { return }
      
      self.titleFirstLabel.text = results[0].title
      self.releaseYearFirstLabel.text = "(\(results[0].releaseYear))"
      self.movieFirstImage.image = results[0].movieImage
      
      self.titleSecondLabel.text = results[1].title
      self.releaseYearSecondLabel.text = "(\(results[1].releaseYear))"
      self.movieSecondImage.image = results[1].movieImage
      
      self.isFirstSelected = false
      self.isSecondSelected = false
      self.selectedMovies.removeAll()
      
      self.updateButton(self.chooseFirstButton, isSelected: self.isFirstSelected)
      self.updateButton(self.chooseSecondButton, isSelected: self.isSecondSelected)
    }
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
