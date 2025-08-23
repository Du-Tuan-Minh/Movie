//
//  CompareMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import DropDown
import FittedSheets
import FirebaseAuth

enum compareModel {
  case compareTwo
  case compareMore
}

protocol CompareMovieDelegate: AnyObject {
  func backUploadMovies(movie: [MovieModel])
  func replaceUploadMovies(_ index: Int)
}

class CompareMoviesViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  weak var delegate: CompareMovieDelegate?
  var selectedMovies: [MovieModel] = []
  var compareModel: compareModel = .compareTwo
  var selectedIndexPath: IndexPath?
  
  //dropdown
  lazy var menu: DropDown = {
    let menu = DropDown()
    menu.width = 150
    menu.dataSource = ItemCompareDropDown.allCases.map(\.rawValue)
    let images = [UIImage(systemName: "trash"), UIImage(systemName: "pencil")]
    menu.cellNib = UINib(nibName: "SelectCell", bundle: nil)
    
    menu.customCellConfiguration = { index, title, cell in
      guard let cell = cell as? SelectCell else {
        return
      }
      cell.configSelectDropDown(selectImage: images[index], selectTitle: title)
    }
    return menu
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupTableView()
    chooseItemDropDown()
  }
}

//MARK: SetupVỉew
extension CompareMoviesViewController {
  private func setupView() {
    titleButton.setTitle("compare".localized(), for: .normal)
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: CompareCell.identifier, bundle: nil), forCellReuseIdentifier: CompareCell.identifier)
    
    //create footer
    guard let footer = Bundle.main.loadNibNamed(FooterCell.identifier, owner: nil, options: nil)?.first as? FooterCell else { return }
    footer.delegate = self
    footer.titleButton = "compare".localized()
    footer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70)
    tableView.tableFooterView = footer
  }
}

//MARK: Action
extension CompareMoviesViewController {
  //bottom sheets
  @IBAction func addTapped(_ sender: Any) {
    let filter = FilterCriteriaBottomSheets()
    let sheet = SheetViewController(controller: filter, sizes: [.fixed(220)])
    filter.listMovieFilter = selectedMovies
    
    filter.chooseFilterCriteria = { [weak self] filteredMovies in
      guard let self = self else { return }
      self.selectedMovies = filteredMovies
      self.tableView.reloadData()
    }
    
    sheet.hasBlurBackground = false
    sheet.cornerRadius = 20
    self.present(sheet, animated: true)
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: TableView
extension CompareMoviesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedMovies.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detailVC = DetailsViewController()
    detailVC.movie = selectedMovies[indexPath.row]
    detailVC.modalPresentationStyle = .fullScreen
    present(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CompareCell.identifier) as? CompareCell else {
      return UITableViewCell()
    }
    cell.delegate = self
    cell.configureCompareCell(with: selectedMovies[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65
  }
}

//MARK: Delegate
extension CompareMoviesViewController: CompareCellDelegate {
  func didTapSelectButton(in cell: CompareCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    selectedIndexPath = indexPath
    menu.anchorView = cell.btn
    menu.show()
  }
}

extension CompareMoviesViewController: FooterCellDelegate {
  func footerClick() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to save comparison", onAction: {})
      return
    }
    
    let compareModelString = compareModel == .compareTwo ? "compareTwo" : "compareMore"
    showLoadingIndicator()
    FirebaseManager.shared.saveComparisonHistory(userId: userId, movies: selectedMovies, compareModel: compareModelString) { [weak self] error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        return
      }
      
      // Clear temporary comparisons
      FirebaseManager.shared.clearTemporaryComparisons(userId: userId) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
          return
        }
        
        let resultVC = ResultsViewController()
        switch self.compareModel {
        case .compareTwo:
          resultVC.resultModel = .ResultTwo
        case .compareMore:
          resultVC.resultModel = .ResultMore
        }
        resultVC.compareMovies = self.selectedMovies
        self.navigationController?.pushViewController(resultVC, animated: true)
      }
    }
  }
}

//MARK: Drop down
extension CompareMoviesViewController {
  func chooseItemDropDown() {
    menu.selectionAction = { [weak self] (index, item) in
      guard let self = self, let selectedIndexPath = self.selectedIndexPath else { return }
      guard let selectItem = ItemCompareDropDown(rawValue: item) else { return }
      
      switch selectItem {
      case .delete:
        self.selectedMovies.remove(at: selectedIndexPath.row)
        self.delegate?.backUploadMovies(movie: selectedMovies )
        self.tableView.reloadData()
        if selectedMovies.count < 2 {
          navigationController?.popViewController(animated: true)
        }
      case .replace:
        delegate?.replaceUploadMovies(selectedIndexPath.row)
        navigationController?.popViewController(animated: true)
      }
    }
  }
}
