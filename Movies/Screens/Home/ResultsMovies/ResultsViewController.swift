//
//  ResultsViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit
import FittedSheets

class ResultsViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var saveButton: UIButton!
  
  var compareMovies: [MovieModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: "ResultsCell", bundle: nil), forCellReuseIdentifier: "ResultsCell")
    
    let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 250))
    guard compareMovies.count >= 2 else { return }
    headerView.configureHeaderView(with: compareMovies[0], secondMovie: compareMovies[1])
    headerView.listMovie = compareMovies
    tableView.tableHeaderView = headerView
  }
  
  private func saveMovie() {
    
  }
  
  @IBAction func saveMoviesTapped(_ sender: Any) {
    self.showAlert(title: "Save movie", message: "Do you want to save this movie to your favorites?") {

      let selectFolderVC = SelectFolderBottomSheets()
      let sheet = SheetViewController(controller: selectFolderVC, sizes: [ .fixed(350)])
      sheet.hasBlurBackground = true
      sheet.cornerRadius = 20
      self.present(sheet, animated: true)
      
    }
  }
}

//MARK: TableView
extension ResultsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell") as? ResultsCell else {
      return UITableViewCell()
    }
    
    guard compareMovies.count >= 2 else { return cell }
    let firstMovie = compareMovies[0]
    let secondMovie = compareMovies[1]
    
    cell.configureResultsCell(with: firstMovie, secondMovie: secondMovie, index: indexPath.row)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
}
