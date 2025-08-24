//
//  DetailsViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//

import UIKit
import AVKit
import AVFoundation
import PhotosUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class DetailsViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var movieImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var durationLabel: UILabel!
  @IBOutlet private weak var userScoreLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var generOneLabel: UILabel!
  @IBOutlet private weak var generTwoLabel: UILabel!
  @IBOutlet private weak var generLabel: UILabel!
  @IBOutlet private weak var releaseDateLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var contentLabel: UILabel!
  @IBOutlet private weak var updateMovieButton: UIButton!
  
  //varible
  var movie: MovieModel?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureDetails()
    setupView()
  }
}

//MARK: Update View
extension DetailsViewController {
  private func setupView() {
    setupText()
    setupButton()
  }
  
  private func setupText() {
    generLabel.text = "genres".localized()
    releaseDateLabel.text = "releaseYear".localized()
    descriptionLabel.text = "description".localized()
    updateMovieButton.setTitle("upload_video".localized(), for: .normal)
  }
  
  private func setupButton() {
    CAGradientLayer().gradientButton(btn: updateMovieButton)
  }
  
  private func configureDetails() {
    guard let movie = movie else { return }
    
    let placeholderImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo") ?? UIImage()
    if let trailerURL = movie.trailerURL, let url = URL(string: trailerURL) {
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self = self, let data = data, error == nil else {
          DispatchQueue.main.async {
            self?.movieImage.image = placeholderImage
          }
          return
        }
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self.movieImage.image = image
          }
        } else {
          DispatchQueue.main.async {
            self.movieImage.image = placeholderImage
          }
        }
      }.resume()
    } else {
      movieImage.image = placeholderImage
    }
    
    titleLabel.text = movie.title
    durationLabel.text = Date().toHoursAndMinutes(time: movie.duration)
    userScoreLabel.text = "\(movie.userScore)"
    releaseYearLabel.text = "\(Date().formattedDate(date: movie.releaseYear ?? Date()))"
    configureGenresLabels(with: movie.genres)
    contentLabel.text = movie.describe
  }
  private func configureGenresLabels(with genres: [GenersModel]) {
    let genresList = genres.map { $0.title }
    
    generOneLabel.text = genresList.isEmpty ? "N/A" : "   \(genresList[0])   "
    generTwoLabel.text = genresList.count > 1 ? "   \(genresList[1])   " : "N/A"
    
    generOneLabel.isHidden = generOneLabel.text == "N/A"
    generTwoLabel.isHidden = generTwoLabel.text == "N/A"
  }
  
  private func playVideo() {
    guard let movie = movie, !movie.videoURLs.isEmpty, let videoURL = URL(string: movie.videoURLs[0]) else {
      showAlert(title: "Error".localized(), message: "No video available".localized(), onAction: {})
      return
    }
    
    let player = AVPlayer(url: videoURL)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    
    present(playerViewController, animated: true) {
      player.play()
    }
  }
}

//MARK: Action
extension DetailsViewController {
  @IBAction func updateMovieTapper(_ sender: Any) {
    guard let movie = movie else {
      showAlert(title: "Error".localized(), message: "No movie data available".localized(), onAction: {})
      return
    }
    
    let addMovieVC = AddMovieViewController()
    addMovieVC.movie = movie
    addMovieVC.status = .update
    present(addMovieVC, animated: true, completion: nil)
  }
  
  @IBAction func playVideoTapped(_ sender: Any) {
    guard let movie = movie, !movie.videoURLs.isEmpty else {  return  }
    let playVideoVC = PlayVideoViewController()
    playVideoVC.movie = movie
    playVideoVC.modalPresentationStyle = .fullScreen
    present(playVideoVC, animated: true, completion: nil)
  }
}
