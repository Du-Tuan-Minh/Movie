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
import Cloudinary
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
  @IBOutlet private weak var uploadVideoButton: UIButton!
  @IBOutlet private weak var trailerButton: UIButton!
  
  //varible
  var movie: MovieModel?
  
  //Cloudinary Initialization
  let cloudinary = CLDCloudinary(configuration: CLDConfiguration(
    cloudName: "dmiiu96yl",
    apiKey: "431475188649929",
    apiSecret: "LTEyhxoLmc6XGOJavyDIH72ZiTM"))
  
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
    uploadVideoButton.setTitle("upload_video".localized(), for: .normal)
  }
  
  private func setupButton() {
    CAGradientLayer().gradientButton(btn: uploadVideoButton)
  }
  
  private func configureDetails() {
    guard let movie = movie else { return }
    // Load PDF from Firebase Storage if pdfURL exists
    if let pdfURL = movie.trailerURL {
      FirebaseManager.shared.storage.child(pdfURL).getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in
        guard let self = self, let data = data, error == nil, let pdfImage = UIImage.convertDataToImage(from: data) else {
          self?.movieImage.image = UIImage(named: "placeholder")
          return
        }
        self.movieImage.image = pdfImage
      }
    } else {
      movieImage.image = UIImage(named: "placeholder")
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
  
  private func uploadVideoToCloudinary(videoURL: URL) {
    guard let movieId = movie?.id else {
      showAlert(title: "Error".localized(), message: "Invalid movie data".localized(), onAction: {})
      return
    }
    
    let params = CLDUploadRequestParams().setResourceType(.video)
    
    cloudinary.createUploader().upload(url: videoURL, uploadPreset: "dutuanminh", params: params) { [weak self] result, error in
      guard let self = self, let url = result?.secureUrl, error == nil else {
        self?.showAlert(title: "Error".localized(), message: error?.localizedDescription ?? "Failed to upload video".localized(), onAction: {})
        return
      }
      
      // Update movie's videoURLs in Firestore
      FirebaseManager.shared.db.collection("movies").document(movieId).collection("videoURLs").document(UUID().uuidString).setData(["url": url]) { error in
        if let error = error {
          self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
        } else {
          // Update local movie object
          self.movie?.videoURLs.append(url)
        }
      }
    }
  }
  
  //play trailer
  private func playCloudinaryVideo() {
    guard let videoURLString = movie?.trailerURL, let videoURL = URL(string: videoURLString) else { return  }
    
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
  @IBAction func trailerVideoTapper(_ sender: Any) {
    playCloudinaryVideo()
  }
  
  @IBAction func uploadVideoTapped(_ sender: Any) {
    var configuration = PHPickerConfiguration()
    configuration.filter = .videos
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    present(picker, animated: true)
  }
  
  @IBAction func playVideoTapped(_ sender: Any) {
    guard let movie = movie, !movie.videoURLs.isEmpty else {  return  }
    let playVideoVC = PlayVideoViewController()
    playVideoVC.movie = movie
    playVideoVC.modalPresentationStyle = .fullScreen
    present(playVideoVC, animated: true, completion: nil)
  }
}

//MARK: Upload video
extension DetailsViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    
    guard let provider = results.first?.itemProvider,
          provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else { return }
    
    provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
      guard let self = self, let tempURL = url, error == nil else { return }
      do {
        // Tạo đường dẫn đích trong thư mục tạm
        let destinationURL = FileManager.default.temporaryDirectory
          .appendingPathComponent(UUID().uuidString)
          .appendingPathExtension("mp4")
        
        try FileManager.default.copyItem(at: tempURL, to: destinationURL)
        self.uploadVideoToCloudinary(videoURL: destinationURL)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
