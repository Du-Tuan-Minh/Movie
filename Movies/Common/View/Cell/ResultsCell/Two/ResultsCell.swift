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
      ResultsCompare(title: "Duration", firstMovieValue: Date().toHoursAndMinutes(time: firstMovie.duration), secondMovieValue: Date().toHoursAndMinutes(time: secondMovie.duration)),
      ResultsCompare(title: "Time", firstMovieValue: "\(firstMovie.releaseYear)", secondMovieValue: "\(secondMovie.releaseYear)"),
      ResultsCompare(title: "Genres", firstMovieValue: firstMovie.genres.joined(separator: ", "), secondMovieValue: secondMovie.genres.joined(separator: ", ")),
      ResultsCompare(title: "User Score", firstMovieValue: "\(firstMovie.userScore)/10", secondMovieValue: "\(secondMovie.userScore)/10"),
      ResultsCompare(title: "Budget", firstMovieValue: "$\(firstMovie.budget)", secondMovieValue: "$\(secondMovie.budget)"),
      ResultsCompare(title: "Revenue", firstMovieValue: "$\(firstMovie.revenue)", secondMovieValue: "$\(secondMovie.revenue)")
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
    let isShowImage = resultItem.title == "User Score"
    
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
