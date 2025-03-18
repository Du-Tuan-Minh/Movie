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
  
  @IBOutlet private weak var genresLabel: UILabel!
  @IBOutlet private weak var durationLabel: UILabel!
  @IBOutlet private weak var saveTimeLabel: UILabel!
  @IBOutlet private weak var revenueLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func configureWatchListCell(with movie: MovieModel, time: Date) {
    if let pdfData = movie.pdfData, let pdfImage = UIImage.convertPDFToImage(from: pdfData) {
      movieImage.image = pdfImage
    } else {
      movieImage.image = UIImage(named: "placeholder")
    }
    titleLabel.text = movie.title
    releaseYearLabel.text = "(\(movie.releaseYear))"
    genresLabel.text = movie.genres.joined(separator: ", ")
    durationLabel.text = "\(movie.duration) minutes"
    saveTimeLabel.text = "\(time)"
    revenueLabel.text = "\(movie.revenue) $"
  }
}
