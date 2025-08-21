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

class ResultsViewController: BaseViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  var compareMovies: [MovieModel] = []
  var resultModel: ResultsModel = .ResultTwo
  private var expandedSections: Set<Int> = []
  private var saveMoreMovies: [MovieModel] = []
  private var selectedMovieIds: Set<String> = []
  var headerViews: [Int: CustomHeaderMoreView] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupTableViewFooterAndHeader()
    setupView()
  }
}

//MARK: SetupView
extension ResultsViewController {
  private func setupView() {
    titleButton.setTitle("results".localized(), for: .normal)
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
  }
  
  private func setupTableViewFooterAndHeader() {
    //create header tablebView on Case ResultTwo
    if resultModel == .ResultTwo {
      let headerView: CustomHeaderView!
      switch UIDevice.current.userInterfaceIdiom {
      case .pad:
        headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 440))
      case .phone:
        headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 250))
      default:
        headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 250))
      }
      guard compareMovies.count >= 2 else { return }
      headerView.configureHeaderView(with: compareMovies[0], secondMovie: compareMovies[1])
      headerView.listMovie = compareMovies
      headerView.onMoviesSelected = { [weak self] selectedMovies in
        self?.saveMoreMovies = selectedMovies
      }
      tableView.tableHeaderView = headerView
    }
    
    //create footer
    guard let footer = Bundle.main.loadNibNamed(FooterCell.identifier, owner: nil, options: nil)?.first as? FooterCell else { return }
    footer.delegate = self
    footer.titleButton = "save".localized()
    footer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 75)
    tableView.tableFooterView = footer
  }
}

//MARK: Action
extension ResultsViewController {
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
      headerView.isChoose = selectedMovieIds.contains(movie.id)
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
      headerView.addGestureRecognizer(tapGesture)
      
      headerViews[section] = headerView
      headerView.isStatusArrow = expandedSections.contains(section)
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
    
    if let headerView = headerViews[section] {
      headerView.isStatusArrow = expandedSections.contains(section)
    }
    tableView.reloadSections(IndexSet(integer: section), with: .automatic)
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
      cell.configureResultsMoreCell(with: compareMovies[indexPath.section])
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
extension ResultsViewController: ChooseButtonSessionDelegate {
  func chooseMovie(view: UIView) {
    guard let headerView = view as? CustomHeaderMoreView else { return }
    let section = headerView.tag
    let selectedMovie = compareMovies[section]
    
    if headerView.isChoose {
      selectedMovieIds.insert(selectedMovie.id)
    } else {
      selectedMovieIds.remove(selectedMovie.id)
    }
    saveMoreMovies = compareMovies.filter { selectedMovieIds.contains($0.id) }
  }
}

//MARK: Delegate
extension ResultsViewController: FooterCellDelegate {
  func footerClick() {
    if saveMoreMovies.count == 0 {
      self.showAlert(title: "no_movies_selected_yet".localized(), message: "", onAction: {})
    } else {
      self.showAlert(title: "save_movie".localized(), message: "Do_you_want_to_save_movie".localized()) {
        let selectFolderVC = SelectFolderBottomSheets()
        selectFolderVC.selectedMovies = self.saveMoreMovies
        let sheet = SheetViewController(controller: selectFolderVC, sizes: [ .fixed(350)])
        sheet.hasBlurBackground = false
        sheet.cornerRadius = 20
        self.present(sheet, animated: true)
      }
      
    }
  }
}
