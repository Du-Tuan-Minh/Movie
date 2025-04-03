//
//  ResultsMoreCell.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//

import UIKit

class ResultsMoreCell: UITableViewCell {
  
  //outlet
  @IBOutlet private weak var genresLabel: UILabel!
  @IBOutlet private weak var DurationLabel: UILabel!
  @IBOutlet private weak var saveTimeLabel: UILabel!
  @IBOutlet private weak var revenueLabel: UILabel!
  @IBOutlet private weak var userScoreImage: UIImageView!
  
  func configureResultsMoreCell(with movie: MovieModel) {
    genresLabel.text = movie.genres.joined(separator: ", ")
    DurationLabel.text = Date().toHoursAndMinutes(time: movie.duration)
    saveTimeLabel.text = "\(movie.releaseYear)"
    revenueLabel.text = "\(movie.revenue)"
    userScoreImage.image = UIImage().convertUseScoreToImage(movieScore: movie.userScore)
  }
}
