//
//  FilterCriteriaBottomSheets.swift
//  Movies
//
//  Created by DuTuanMinh on 23/3/25.
//

import UIKit

enum FilterCriteriaModel: String, CaseIterable {
  case coment = "Coment"
  case rating = "Rating"
  case releaseYear = "Release Year"
}

class FilterCriteriaBottomSheets: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  
  //variable
  private let itemFilterCriteria = FilterCriteriaModel.allCases.map(\.rawValue)
  var listMovieFilter = [MovieModel]()
  var chooseFilterCriteria: (([MovieModel]) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectFolderCell")
  }
}

//MARK: TableView
extension FilterCriteriaBottomSheets: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemFilterCriteria.count
  }
  
  // filter
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedFilter = FilterCriteriaModel(rawValue: itemFilterCriteria[indexPath.row]) else { return }
    guard !listMovieFilter.isEmpty else {
      dismiss(animated: true)
      return
    }
    switch selectedFilter {
    case .coment:
      listMovieFilter.sort{ $0.comments.count < $1.comments.count}
    case .rating:
      listMovieFilter.sort{ $0.userScore < $1.userScore}
    case .releaseYear:
      listMovieFilter.sort { $0.releaseYear < $1.releaseYear }
    }
    
    chooseFilterCriteria?(listMovieFilter)
    dismiss(animated: true)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFolderCell")  else {
      return UITableViewCell()
    }
    cell.textLabel?.text = itemFilterCriteria[indexPath.row]
    cell.backgroundColor = .lightBlue
    cell.textLabel?.textAlignment = .center
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
}
