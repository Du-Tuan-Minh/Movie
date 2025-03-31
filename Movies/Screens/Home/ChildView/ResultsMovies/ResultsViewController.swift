//
//  ResultsViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 3/3/25.
//

import UIKit
import FittedSheets

enum ResultsModel {
  case ResultMore
  case ResultTwo
}

class ResultsViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var saveButton: UIButton!
  
  //variable
  var compareMovies: [MovieModel] = []
  var resultModel: ResultsModel = .ResultTwo
  private var expandedSections: Set<Int> = []
  private var saveMoreMovies: [MovieModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupTableView()
  }
  
  private func setupView() {
    CAGradientLayer().addGradient(to: saveButton, colors: [UIColor(resource: .lightBlue), UIColor(resource: .violet)], startPoint:  CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    switch resultModel {
    case .ResultMore:
      tableView.register(UINib(nibName: "ResultsMoreCell", bundle: nil), forCellReuseIdentifier: "ResultsMoreCell")
    case .ResultTwo:
      tableView.register(UINib(nibName: "ResultsCell", bundle: nil), forCellReuseIdentifier: "ResultsCell")
    }
    //create header tablebView on Case ResultTwo
    if resultModel == .ResultTwo {
      let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 250))
      guard compareMovies.count >= 2 else { return }
      headerView.configureHeaderView(with: compareMovies[0], secondMovie: compareMovies[1])
      headerView.listMovie = compareMovies
      headerView.onMoviesSelected = { [weak self] selectedMovies in
        self?.compareMovies = selectedMovies
      }
      tableView.tableHeaderView = headerView
    }
  }
  
  //create bottmSheet
  @IBAction func saveMoviesTapped(_ sender: Any) {
    self.showAlert(title: "Save movie", message: "Do you want to save this movie to your favorites?") {
      let selectFolderVC = SelectFolderBottomSheets()
      selectFolderVC.selectedMovies = self.compareMovies
      let sheet = SheetViewController(controller: selectFolderVC, sizes: [ .fixed(350)])
      sheet.hasBlurBackground = true
      sheet.cornerRadius = 20
      self.present(sheet, animated: true)
    }
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: TableView
extension ResultsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    
    switch resultModel.self {
    case .ResultMore:
      return compareMovies.count
    case .ResultTwo:
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch resultModel.self {
    case .ResultMore:
      return expandedSections.contains(section) ? 1 : 0
    case .ResultTwo:
      return 6
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    switch resultModel.self {
    case .ResultMore:
      let headerView = CustomHeaderMoreView()
      headerView.delegate = self
      headerView.tag = section
      
      guard compareMovies.indices.contains(section) else { return headerView }
      let movie = compareMovies[section]
      headerView.configureCustomHeaderMoreView(with: movie, at: section)
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
      headerView.addGestureRecognizer(tapGesture)
      return headerView
    case .ResultTwo:
      return UIView()
    }
  }
  
  @objc private func toggleSection(_ sender: UITapGestureRecognizer) {
    guard let section = sender.view?.tag else { return }
    if expandedSections.contains(section) {
      expandedSections.remove(section)
    } else {
      expandedSections.insert(section)
    }
    tableView.reloadSections(IndexSet(integer: section), with: .automatic)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch resultModel.self {
    case .ResultMore:
      break
    case .ResultTwo:
      break
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    switch resultModel.self {
    case .ResultMore:
      return 55
    case .ResultTwo:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch resultModel {
    case .ResultMore:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsMoreCell") as? ResultsMoreCell else {
        return UITableViewCell()
      }
      cell.configureResultsMoreCell(with: compareMovies[indexPath.row])
      return cell
    case .ResultTwo:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell") as? ResultsCell else {
        return UITableViewCell()
      }
      
      guard compareMovies.count >= 2 else { return cell }
      let firstMovie = compareMovies[0]
      let secondMovie = compareMovies[1]

      cell.configureResultsCell(with: firstMovie, secondMovie: secondMovie, index: indexPath.row)
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    switch resultModel.self {
    case .ResultMore:
      return 245
    case .ResultTwo:
      return 95
    }
  }
}

//MARK: Delegate
extension ResultsViewController: CustomHeaderMoreViewDelegate {
  func chooseMovie(view: UIView) {
    guard let headerView = view as? CustomHeaderMoreView else { return }
    let section = headerView.tag
    guard compareMovies.indices.contains(section) else { return }
    
    let selectedMovie = compareMovies[section]
    
    if headerView.isChoose {
      if !saveMoreMovies.contains(where: { $0.id == selectedMovie.id }) {
        saveMoreMovies.append(selectedMovie)
      }
    } else {
      saveMoreMovies.removeAll { $0.id == selectedMovie.id }
    }
    compareMovies = saveMoreMovies
  }
}
