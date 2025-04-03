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
  
  private var isStatus = false
  weak var delegate: NewFolderPopUpDelegate?
  var modelStatus: createFolderModel = .folderWatchlist
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configView()
  }
}

//MARK: Setup View
extension NewFolderPopUp {
  private func configView() {
    view.backgroundColor = .clear
    self.configurePopUp(blureView: blureView, contentView: contentView)
    cancelButton.backgroundColor = UIColor(resource: .gray)
    cancelButton.setTitleColor(.black, for: .normal)
    yesButton.backgroundColor = UIColor(resource: .gray)
    yesButton.setTitleColor(.black, for: .normal)
  }
  
  func appear(sender: UIViewController) {
    sender.present(self, animated: true) {
      self.showPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
  
  func configureButton(button: UIButton) {
    if isStatus {
      button.backgroundColor = UIColor(resource: .blueSky)
      button.setTitleColor(.white, for: .normal)
    } else {
      button.backgroundColor = UIColor(resource: .gray)
      button.setTitleColor(.black, for: .normal)
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
