//
//  FilterCriteriaBottomSheets.swift
//  Movies
//
//  Created by DuTuanMinh on 23/3/25.
//

import UIKit

enum FilterCriteriaModel: String, CaseIterable {
  case coment
  case rating
  case releaseYear
  
  var title: String {
    switch self {
    case .coment:
      return "coment"
    case .rating:
      return "rating"
    case .releaseYear:
      return "releaseYear"
    }
  }
}

class FilterCriteriaBottomSheets: UIViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  
  //variable
  private let itemFilterCriteria = FilterCriteriaModel.allCases.map(\.title)
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
    
    let sortedMovies = listMovieFilter.sorted {
      switch selectedFilter {
      case .coment: return $0.comments.count < $1.comments.count
      case .rating: return $0.userScore < $1.userScore
      case .releaseYear: return Date().getYear(date: $0.releaseYear ?? Date()) < Date().getYear(date: $1.releaseYear ?? Date())
      }
    }
    chooseFilterCriteria?(sortedMovies)
    dismiss(animated: true)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFolderCell")  else {
      return UITableViewCell()
    }
    cell.textLabel?.text = itemFilterCriteria[indexPath.row].localized()
    cell.textLabel?.textColor = .lightBlue
    cell.backgroundColor = UIColor(resource: .blue)
    cell.textLabel?.textAlignment = .center
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
