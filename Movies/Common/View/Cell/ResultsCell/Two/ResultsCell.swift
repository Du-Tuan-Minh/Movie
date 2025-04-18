//
//  ResultsCell.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

struct ResultsCompare {
  let title: String
  let firstMovieValue: String
  let secondMovieValue: String
}

extension ResultsCompare {
  static func compareMovies(firstMovie: MovieModel, secondMovie: MovieModel) -> [ResultsCompare] {
    return [
      ResultsCompare(title: "duration".localized(), firstMovieValue: Date().toHoursAndMinutes(time: firstMovie.duration), secondMovieValue: Date().toHoursAndMinutes(time: secondMovie.duration)),
      ResultsCompare(title: "time".localized(), firstMovieValue: "\(Date().getYear(date: firstMovie.releaseYear ?? Date()))", secondMovieValue: "\(Date().getYear(date: secondMovie.releaseYear ?? Date()))"),
      ResultsCompare(title: "genres".localized(), firstMovieValue: firstMovie.genres.map { $0.title }.joined(separator: ", "), secondMovieValue: secondMovie.genres.map { $0.title }.joined(separator: ", ")),
      ResultsCompare(title: "userScore".localized(), firstMovieValue: "\(firstMovie.userScore)/10", secondMovieValue: "\(secondMovie.userScore)/10"),
      ResultsCompare(title: "budget".localized(), firstMovieValue: "$\(firstMovie.budget)", secondMovieValue: "$\(secondMovie.budget)"),
      ResultsCompare(title: "revenue".localized(), firstMovieValue: "$\(firstMovie.revenue)", secondMovieValue: "$\(secondMovie.revenue)")
    ]
  }
}

class ResultsCell: UITableViewCell {
  
  //outlet
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var separateImage: UIImageView!
  @IBOutlet private weak var titleFirstLabel: UILabel!
  @IBOutlet private weak var titleSecondLabel: UILabel!
  @IBOutlet private weak var movieFirstImage: UIImageView!
  @IBOutlet private weak var movieSecondImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    separateImage.image = UIImage(resource: .classify)
  }
  
  func configureResultsCell(with firstMovie: MovieModel, secondMovie: MovieModel, index: Int) {
    let results = ResultsCompare.compareMovies(firstMovie: firstMovie, secondMovie: secondMovie)
    guard index < results.count else { return }
    
    let resultItem = results[index]
    titleLabel.text = resultItem.title
    let isShowImage = resultItem.title == "userScore".localized()
    
    titleFirstLabel.isHidden = isShowImage
    titleSecondLabel.isHidden = isShowImage
    movieFirstImage.isHidden = !isShowImage
    movieSecondImage.isHidden = !isShowImage
    
    if isShowImage {
      movieFirstImage.image = UIImage().convertUseScoreToImage(movieScore: firstMovie.userScore)
      movieSecondImage.image = UIImage().convertUseScoreToImage(movieScore: secondMovie.userScore)
    } else {
      titleFirstLabel.text = resultItem.firstMovieValue
      titleSecondLabel.text = resultItem.secondMovieValue
    }
  }
}
