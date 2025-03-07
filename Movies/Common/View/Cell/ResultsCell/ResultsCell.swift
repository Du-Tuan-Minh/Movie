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
            ResultsCompare(title: "Duration", firstMovieValue: "\(firstMovie.duration) min", secondMovieValue: "\(secondMovie.duration) min"),
            ResultsCompare(title: "Time", firstMovieValue: "\(firstMovie.releaseYear)", secondMovieValue: "\(secondMovie.releaseYear)"),
            ResultsCompare(title: "Genres", firstMovieValue: firstMovie.genres.joined(separator: ", "), secondMovieValue: secondMovie.genres.joined(separator: ", ")),
            ResultsCompare(title: "User Score", firstMovieValue: "\(firstMovie.userScore)/10", secondMovieValue: "\(secondMovie.userScore)/10"),
            ResultsCompare(title: "Budget", firstMovieValue: "$\(firstMovie.budget)M", secondMovieValue: "$\(secondMovie.budget)M"),
            ResultsCompare(title: "Revenue", firstMovieValue: "$\(firstMovie.revenue)M", secondMovieValue: "$\(secondMovie.revenue)M")
        ]
    }
}


class ResultsCell: UITableViewCell {

  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var separateImage: UIImageView!
  @IBOutlet private weak var titleFirstLabel: UILabel!
  @IBOutlet private weak var titleSecondLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  func configureResultsCell(with firstMovie: MovieModel, secondMovie: MovieModel, index: Int) {
       let results = ResultsCompare.compareMovies(firstMovie: firstMovie, secondMovie: secondMovie)
       guard index < results.count else { return }
       
       let resultItem = results[index]
       titleLabel.text = resultItem.title
       titleFirstLabel.text = resultItem.firstMovieValue
       titleSecondLabel.text = resultItem.secondMovieValue
   }
}
