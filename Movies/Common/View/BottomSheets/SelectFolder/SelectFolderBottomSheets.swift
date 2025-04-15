//
//  SelectFolderBottomSheets.swift
//  Movies
//
//  Created by DuTuanMinh on 14/3/25.
//

import UIKit
import RealmSwift

class SelectFolderBottomSheets: UIViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var newFolderButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  //variable
  var selectedMovies: [MovieModel] = []
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupTableView()
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
  
  private func getTitleFolder() -> Results<WatchlistFolderModel>{
    return try! Realm().objects(WatchlistFolderModel.self)
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
    return getTitleFolder().count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let savePopUp = SaveMoviePopUp()
    savePopUp.saveMovies = selectedMovies
    savePopUp.textNote = getTitleFolder()[indexPath.row].title
    savePopUp.folderID = getTitleFolder()[indexPath.row].id
    savePopUp.appear(sender: self)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFolderCell")  else { return UITableViewCell() }
    cell.textLabel?.text = getTitleFolder()[indexPath.row].title
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
    tableView.reloadData()
  }
}
