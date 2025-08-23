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
    let genres = movie.genres.map { $0.title }
    genresLabel.text = genres.joined(separator: ", ")
    DurationLabel.text = Date().toHoursAndMinutes(time: movie.duration)
    saveTimeLabel.text = "(\(Date().formattedDate(date: movie.releaseYear ?? Date())))"
    revenueLabel.text = "\(movie.revenue)"
    userScoreImage.image = UIImage().convertUseScoreToImage(movieScore: movie.userScore)
  }
}
