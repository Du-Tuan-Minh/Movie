//
//  DetailsViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 25/3/25.
//

import UIKit
import AVKit
import AVFoundation
import RealmSwift
import PhotosUI
import Cloudinary

class DetailsViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var movieImage: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var durationLabel: UILabel!
  @IBOutlet private weak var userScoreLabel: UILabel!
  @IBOutlet private weak var releaseYearLabel: UILabel!
  @IBOutlet private weak var generOneLabel: UILabel!
  @IBOutlet private weak var generTwoLabel: UILabel!
  @IBOutlet private weak var uploadVideoButton: UIButton!
  @IBOutlet private weak var trailerButton: UIButton!
  
  //varible
  var movie: MovieModel?
  let realm = try! Realm()
  
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
    CAGradientLayer().gradientButton(btn: uploadVideoButton)
    guard let movie = movie else {return}
    trailerButton.isHidden = movie.videoURL == nil
  }
  
  private func configureDetails() {
    guard let movie = movie else {return}
    if let pdfData = movie.pdfData, let pdfImage = UIImage.convertPDFToImage(from: pdfData) {
      movieImage.image = pdfImage
    } else {
      movieImage.image = UIImage(named: "placeholder")
    }
    titleLabel.text = movie.title
    durationLabel.text = "\(movie.duration) minutes"
    userScoreLabel.text = "\(movie.userScore)%"
    releaseYearLabel.text = "\(movie.releaseYear)"
    generOneLabel.text = "  " + "\(movie.genres[0])" + "  "
    generTwoLabel.text = "  1234  "
  }
  
  private func uploadVideoToCloudinary(videoURL: URL) {
    let params = CLDUploadRequestParams().setResourceType(.video)
    
    cloudinary.createUploader().upload(url: videoURL,
                                       uploadPreset: "dutuanminh",
                                       params: params, completionHandler:  { [weak self] result, error in
      guard let self = self, let url = result?.secureUrl, error == nil else { return }
      
      try? self.realm.write {
        guard let movie = self.movie else {return}
        movie.videoURL = url
        self.realm.add(movie)
      }
    })
  }
  
  //play trailer
  private func playCloudinaryVideo() {
    guard let videoURLString = movie?.videoURL, let videoURL = URL(string: videoURLString) else { return  }
    
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
