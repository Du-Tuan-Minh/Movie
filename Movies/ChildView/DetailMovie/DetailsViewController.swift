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
  @IBOutlet private weak var commentButton: UIButton!
  
  //varible
  var movie: MovieModel?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    configureDetails()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    FirebaseManager.shared.getUserRole { role in
      self.updateMovieButton.isHidden = role != 1
    }
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
    
    UIImage().convertURLtoImage(movie: movie, movieImage: movieImage)
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
  
  @IBAction func commentTapped(_ sender: Any) {
    guard let movie = movie else {
      showAlert(title: "Error", message: "No movie data available", onAction: {})
      return
    }
    let commentVC = CommentViewController()
    commentVC.movie = movie
    commentVC.modalPresentationStyle = .fullScreen
    present(commentVC, animated: true, completion: nil)
  }
}
