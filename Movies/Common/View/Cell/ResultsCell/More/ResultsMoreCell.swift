//
//  ResultsMoreCell.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//

import UIKit

class ResultsMoreCell: UITableViewCell {

  @IBOutlet private weak var genresLabel: UILabel!
  @IBOutlet private weak var DurationLabel: UILabel!
  @IBOutlet private weak var saveTimeLabel: UILabel!
  @IBOutlet private weak var revenueLabel: UILabel!
  @IBOutlet private weak var userScoreImage: UIImageView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  func configureResultsMoreCell(with movie: MovieModel) {
    genresLabel.text = movie.genres.joined(separator: ", ")
    DurationLabel.text = "\(movie.duration)"
    saveTimeLabel.text = "\(movie.releaseYear)"
    revenueLabel.text = "\(movie.revenue)"
    userScoreImage.image = UIImage().convertUseScoreToImage(movieScore: movie.userScore)
  }
}
