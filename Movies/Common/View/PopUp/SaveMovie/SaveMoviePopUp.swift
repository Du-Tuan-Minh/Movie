//
//  SaveMoviePopUp.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit
import RealmSwift

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
    titleLabel.text = "Note \n \(textNote ?? "")"
    
    CAGradientLayer().addGradient(to: saveButton, colors: [UIColor(resource: .lightBlue), UIColor(resource: .violet)], startPoint:  CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  private func configView() {
    view.backgroundColor = .clear
    self.configurePopUp(blureView: blureView, contentView: contentView)
  }
  
  func appear(sender: UIViewController) {
    sender.present(self, animated: true) {
      self.showPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
  
  private func saveMoviesToRealm() {
    guard let movies = saveMovies, !movies.isEmpty else {
      return
    }
    let realm = try! Realm()
    
    let saveMovie = WatchlistModel()
    saveMovie.movie.append(objectsIn: movies)
    saveMovie.note = descriptionTextView.text ?? ""
    
    try! realm.write {
      realm.add(saveMovie)
    }
    
    if let folderID = folderID, !folderID.isEmpty {
      if let existingFolder = realm.object(ofType: WatchlistFolderModel.self, forPrimaryKey: folderID) {
        try! realm.write {
          existingFolder.movies.append(saveMovie)
        }
      }
    }
  }
  
  @IBAction func saveMovieTapped(_ sender: Any) {
    saveMoviesToRealm()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
}
