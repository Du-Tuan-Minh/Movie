//
//  SelectFolderBottomSheets.swift
//  Movies
//
//  Created by DuTuanMinh on 14/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreSwift

class SelectFolderBottomSheets: UIViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var newFolderButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  
  //variable
  var selectedMovies: [MovieModel] = []
  private var folders: [WatchlistFolderModel] = []
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupTableView()
    fetchFolders()
  }
  
  private func setupView() {
    titleLabel.text = "select_folder".localized()
    newFolderButton.setTitle("new_folder".localized(), for: .normal)
    CAGradientLayer().gradientButton(btn: newFolderButton)
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectFolderCell")
  }
  
  private func fetchFolders() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error".localized(), message: "You must be logged in to view folders".localized(), onAction: {})
      return
    }
    
    FirebaseManager.shared.fetchWatchlistFolders(userId: userId) { [weak self] folders, error in
      guard let self = self else { return }
      if let error = error {
        self.showAlert(title: "Error".localized(), message: error.localizedDescription, onAction: {})
        return
      }
      self.folders = folders ?? []
      self.tableView.reloadData()
    }
  }
  
  @IBAction func createFolderTapped(_ sender: Any) {
    let newfolder = NewFolderPopUp()
    newfolder.delegate = self
    newfolder.appear(sender: self)
  }
}

//MARK: TableView
extension SelectFolderBottomSheets: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return folders.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let savePopUp = SaveMoviePopUp()
    savePopUp.saveMovies = selectedMovies
    savePopUp.textNote = folders[indexPath.row].title
    savePopUp.folderID = folders[indexPath.row].id
    savePopUp.appear(sender: self)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFolderCell")  else { return UITableViewCell() }
    cell.textLabel?.text = folders[indexPath.row].title
    cell.contentView.backgroundColor = UIColor(resource: .graySmoke)
    cell.textLabel?.textColor = UIColor(resource: .lightBlue)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
}

//MARK: Delegate
extension SelectFolderBottomSheets: NewFolderPopUpDelegate {
  func didCreateNewFolder() {
    fetchFolders()
  }
}
