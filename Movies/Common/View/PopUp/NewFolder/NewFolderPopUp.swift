//
//  NewFolderPopUp.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import RealmSwift

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
      button.setTitleColor(UIColor.red, for: .normal)
    } else {
      button.backgroundColor = UIColor(resource: .gray)
      button.setTitleColor(UIColor(resource: .violet), for: .normal)
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
    isStatus.toggle()
    configureButton(button: yesButton)
    
    let realm = try! Realm()
    var newFolder: Object
    
    if modelStatus == .folderWatchlist {
      let folder = WatchlistFolderModel()
      folder.title = titleTextField.text ?? ""
      newFolder = folder
    } else {
      let folder = HistoryFolderModel()
      folder.folderName = titleTextField.text ?? ""
      newFolder = folder
    }
    
    try! realm.write {
      realm.add(newFolder)
    }
    delegate?.didCreateNewFolder()
    hiden()
  }
}
