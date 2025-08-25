//
//  WatchlistCell.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit

class WatchlistCell: UITableViewCell {
  //outlet
  @IBOutlet private weak var movieImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var userScoreImage: UIImageView!
  @IBOutlet private weak var genresLabel: UILabel!
  @IBOutlet private weak var durationLabel: UILabel!
  @IBOutlet private weak var saveTimeLabel: UILabel!
  @IBOutlet private weak var revenueLabel: UILabel!
  
  static let identifier: String = "WatchlistCell"
  
  func configureWatchListCell(with movie: MovieModel, time: Date, tag: Int) {
    UIImage().convertURLtoImage(movie: movie, movieImage: movieImage)
    
    userScoreImage.image = UIImage().convertUseScoreToImage(movieScore: movie.userScore)
    titleLabel.text = movie.title
    releaseYearLabel.text = "(\(Date().getYear(date: movie.releaseYear ?? Date())))"
    let genres = movie.genres.map { $0.title }
    genresLabel.text = genres.joined(separator: ", ")
    durationLabel.text = Date().toHoursAndMinutes(time: movie.duration)
    saveTimeLabel.text = "\(Date().formattedDate(date: time))"
    revenueLabel.text = "\(movie.revenue) $"
    
    titleLabel.textColor = tag % 2 == 0 ? UIColor(resource: .lightBlue) : UIColor(resource: .violet)
  }
}
