//
//  SaveMoviePopUp.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SaveMoviePopUp: UIViewController {
  //outlet
  @IBOutlet private weak var descriptionTextView: UITextView!
  @IBOutlet private weak var saveButton: UIButton!
  @IBOutlet private weak var blureView: UIView!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var titleLabel: UILabel!
  
  //variable
  var saveMovies: [MovieModel]?
  var textNote: String?
  var folderID: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configView()
    setupView()
  }
  
  private func setupView() {
    titleLabel.text = "\(textNote ?? "")"
    saveButton.setTitle("save".localized(), for: .normal)
    CAGradientLayer().gradientButton(btn: saveButton)
  }
  
  private func configView() {
    view.backgroundColor = .clear
    self.configurePopUp(blureView: blureView, contentView: contentView)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
    blureView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func dismissPopup() {
    self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
  }
  
  func appear(sender: UIViewController) {
    sender.present(self, animated: true) {
      self.showPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
  
  private func saveMoviesToFirebase() {
        guard let movies = saveMovies, !movies.isEmpty, let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error".localized(), message: "No movies selected or user not logged in".localized(), onAction: {})
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var errors: [Error] = []
        var watchlistIds: [String] = []
        
        // Save each movie to watchlist
        for movie in movies {
            guard let movieId = movie.id else { continue }
            dispatchGroup.enter()
            FirebaseManager.shared.addToWatchlist(userId: userId, movie: movie) { error in
                if let error = error {
                    errors.append(error)
                } else {
                    watchlistIds.append(movieId)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if !errors.isEmpty {
                self.showAlert(title: "Error".localized(), message: errors.first?.localizedDescription ?? "Failed to save movies".localized(), onAction: {})
                return
            }
            
            // Update folder if folderID exists
            if let folderID = self.folderID, !folderID.isEmpty {
                FirebaseManager.shared.db.collection("users").document(userId).collection("watchlist_folders").document(folderID).updateData([
                    "movies": FieldValue.arrayUnion(watchlistIds)
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
                    } else {
                        self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
                    }
                }
            } else {
                self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
            }
        }
    }
  
  @IBAction func saveMovieTapped(_ sender: Any) {
    saveMoviesToFirebase()
  }
}
