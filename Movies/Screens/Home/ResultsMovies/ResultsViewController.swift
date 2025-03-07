//
//  ResultsViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit

class ResultsViewController: UIViewController {
  
  //outlet
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var saveButton: UIButton!
  
  var compareMovies: [MovieModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: "ResultsCell", bundle: nil), forCellReuseIdentifier: "ResultsCell")
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
