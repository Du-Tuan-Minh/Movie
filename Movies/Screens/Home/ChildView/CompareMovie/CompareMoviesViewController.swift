//
//  CompareMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import DropDown
import RealmSwift
import FittedSheets

enum compareModel {
  case compareTwo
  case compareMore
}

protocol CompareMovieDelegate: AnyObject {
  func backUploadMovies()
  func replaceUploadMovies(_ index: Int)
}

class CompareMoviesViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  
  //variable
  final private let reuseIdentifier: String = "CompareCell"
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
    setupTableView()
    chooseItemDropDown()
    self.enableEdgePanBackGesture()
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
    
    sheet.hasBlurBackground = true
    sheet.cornerRadius = 20
    self.present(sheet, animated: true)
  }
}

//MARK: SetupVỉew
extension CompareMoviesViewController {
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
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
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? CompareCell else {
      return UITableViewCell()
    }
    cell.delegate = self
    cell.configureCompareCell(with: selectedMovies[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = Bundle.main.loadNibNamed(FooterCell.identifier, owner: nil, options: nil)?.first as? FooterCell
    footer?.delegate = self
    footer?.titleButton = "Compare"
    return footer
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 60
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
    let realm = try! Realm()
    let history = HistoryFolderModel()
    
    try! realm.write {
      history.comparisons.append(objectsIn: self.selectedMovies)
      realm.add(history)
    }
    
    let resultVC = ResultsViewController()
    switch compareModel {
    case .compareTwo:
      resultVC.resultModel = .ResultTwo
    case .compareMore:
      resultVC.resultModel = .ResultMore
    }
    resultVC.compareMovies = selectedMovies
    navigationController?.pushViewController(resultVC, animated: true)
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
        self.tableView.reloadData()
        if selectedMovies.count < 2 {
          delegate?.backUploadMovies()
          navigationController?.popViewController(animated: true)
          
        }
      case .replace:
        delegate?.replaceUploadMovies(selectedIndexPath.row)
        navigationController?.popViewController(animated: true)
      }
    }
  }
}
