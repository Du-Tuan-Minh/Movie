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

class NewFolderPopUp: UIViewController {
  
  //outlet
  @IBOutlet private weak var blureView: UIView!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var cancelButton: UIButton!
  @IBOutlet private weak var yesButton: UIButton!
  @IBOutlet private weak var titleTextField: UITextField!
  
  private var isStatus = false
  weak var delegate: NewFolderPopUpDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configView()
    
  }
  
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
  
  @IBAction func cancelTapped(_ sender: Any) {
    isStatus.toggle()
    configureButton(button: cancelButton)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
  
  @IBAction func createFolderTapped(_ sender: Any) {
    isStatus.toggle()
    configureButton(button: yesButton)
    
    let realm = try! Realm()
    let newFolder = WatchlistFolderModel()
    newFolder.title = titleTextField.text ?? ""
    
    try! realm.write {
      realm.add(newFolder)
    }
    
    delegate?.didCreateNewFolder()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.hinderPopUp(blureView: self.blureView, contentView: self.contentView)
    }
  }
}
