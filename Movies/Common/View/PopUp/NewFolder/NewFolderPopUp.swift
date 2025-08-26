//
//  NewFolderPopUp.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol NewFolderPopUpDelegate: AnyObject {
  func didCreateNewFolder()
}

enum createFolderModel {
  case folderWatchlist
  case folderHistory
}

class NewFolderPopUp: UIViewController {
  //outlet
  @IBOutlet private weak var blureView: UIView!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var cancelButton: UIButton!
  @IBOutlet private weak var yesButton: UIButton!
  @IBOutlet private weak var titleTextField: UITextField!
  @IBOutlet private weak var titleLabel: UILabel!
  
  //variable
  private var isStatus = false
  weak var delegate: NewFolderPopUpDelegate?
  var modelStatus: createFolderModel = .folderWatchlist
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
}

//MARK: Setup View
extension NewFolderPopUp {
  private func setupView() {
    setupButton()
    setupText()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
    blureView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func dismissPopup() {
    self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
  }
  
  private func setupText() {
    titleLabel.text = "new_folder".localized()
    yesButton.setTitle("yes".localized(), for: .normal)
    cancelButton.setTitle("cancel".localized(), for: .normal)
  }
  
  private func setupButton() {
    self.configurePopUp(blureView: blureView, contentView: contentView)
  }
  
  func appear(sender: UIViewController) {
    sender.present(self, animated: true) {
      self.showPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
  
  func configureButton(button: UIButton) {
    if isStatus {
      CAGradientLayer().gradientButton(btn: button)
    } else {
      button.backgroundColor = UIColor(resource: .gray)
    }
  }
  
  private func hiden() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
}

//MARK: Action
extension NewFolderPopUp {
  @IBAction func cancelTapped(_ sender: Any) {
    isStatus.toggle()
    configureButton(button: cancelButton)
    hiden()
  }
  
  @IBAction func createFolderTapped(_ sender: Any) {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error".localized(), message: "You must be logged in to create a folder".localized(), onAction: {})
      return
    }
    
    isStatus.toggle()
    configureButton(button: yesButton)
    
    let folderName = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if folderName.isEmpty {
      showAlert(title: "Error".localized(), message: "Folder name cannot be empty".localized(), onAction: {})
      return
    }
    
    let folderId = UUID().uuidString
    if modelStatus == .folderWatchlist {
      let folder = WatchlistFolderModel(id: folderId, title: folderName, movies: [], createdDate: Date())
      FirebaseManager.shared.addFolder(userId: userId, folder: folder, type: .watchlist) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
        } else {
          self.delegate?.didCreateNewFolder()
          self.hiden()
        }
      }
    } else {
      let folder = HistoryFolderModel(id: folderId, folderName: folderName, comparisons: [], createdDate: Date())
      FirebaseManager.shared.addFolder(userId: userId, folder: folder, type: .history) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
        } else {
          self.delegate?.didCreateNewFolder()
          self.hiden()
        }
      }
    }
  }
}
