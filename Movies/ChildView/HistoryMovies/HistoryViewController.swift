//
//  HistoryViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit
import RealmSwift

class HistoryViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "SearchCell"
  final private let reuseIdentifierHistoryHeaderView: String = "HistoryHeaderView"
  private var groupedMovies: [(createdDate: Date, movies: [MovieModel])] = []
  private var listChoose: IndexSet = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadMovie()
    setupView()
    setupCollectionView()
  }
}

//MARK: setupView
extension HistoryViewController {
  private func setupView() {
    titleButton.setTitle("history".localized(), for: .normal)
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    
    collectionView.register(
      UINib(nibName: reuseIdentifierHistoryHeaderView, bundle: nil),
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: reuseIdentifierHistoryHeaderView
    )
  }
}

//MARK: Realm
extension HistoryViewController {
  private func getListHistory() -> Results<HistoryFolderModel> {
    return try! Realm().objects(HistoryFolderModel.self)
  }
  //  private func loadMovie() {
  //    let historyList = getListHistory()
  //    groupedMovies = historyList.map { folder in
  //      (createdDate: folder.createdDate, movies: Array(folder.comparisons))
  //    }.sorted { $0.createdDate > $1.createdDate }
  //    collectionView.reloadData()
  //  }
  private func loadMovie() {
    let historyList = getListHistory()
    var moviesGroupedByDate = [Date: [MovieModel]]()
    
    for folder in historyList {
      let dateOnly = Calendar.current.startOfDay(for: folder.createdDate)
      moviesGroupedByDate[dateOnly, default: []].append(contentsOf: Array(folder.comparisons))
    }
    
    groupedMovies = moviesGroupedByDate.map { (date: Date, movies: [MovieModel]) -> (createdDate: Date, movies: [MovieModel]) in
      return (createdDate: date, movies: movies)
    } .sorted { $0.createdDate > $1.createdDate }
    collectionView.reloadData()
  }
}

//MARK: Action
extension HistoryViewController {
  @IBAction func deleteSessionTaped(_ sender: Any) {
    let realm = try! Realm()
    try! realm.write {
      let datesToDelete = listChoose.map { groupedMovies[$0].createdDate }
      
      let allHistory = realm.objects(HistoryFolderModel.self)
      
      if datesToDelete.isEmpty {
        self.showAlert(title: "do_you_want_to_delete_everything".localized(), message: "") {
          realm.delete(realm.objects(HistoryFolderModel.self))
          self.groupedMovies.removeAll()
        }
      } else {
        for date in datesToDelete {
          let itemsToDelete = allHistory.filter("createdDate == %@", date)
          realm.delete(itemsToDelete)
        }
        
        for index in listChoose.sorted(by: >) {
          groupedMovies.remove(at: index)
        }
        listChoose.removeAll()
      }
      collectionView.reloadData()
    }
  }
  
  //  @IBAction func cleanAllTapped(_ sender: Any) {
  //
  //      let realm = try! Realm()
  //      try! realm.write {
  //
  //
  //        self.collectionView.reloadData()
  //      }
  //    }
  //  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: CollectionView
extension HistoryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return groupedMovies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return groupedMovies[section].movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = DetailsViewController()
    let selectedMovie = groupedMovies[indexPath.section].movies[indexPath.row]
    detailVC.movie = selectedMovie
    detailVC.modalPresentationStyle = .fullScreen
    present(detailVC, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SearchCell else {
      return UICollectionViewCell()
    }
    let movieItem = groupedMovies[indexPath.section].movies[indexPath.row]
    cell.configSearchCell(with: movieItem)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      let totalSpacing: CGFloat = 100
      let width = (collectionView.frame.width - totalSpacing) / 3
      return CGSize(width: width, height: 400)
    case .phone:
      let totalSpacing: CGFloat = 10
      let width = (collectionView.frame.width - totalSpacing) / 3
      return CGSize(width: width, height: 250)
    default:
      let width = (collectionView.frame.width - 10) / 2
      return CGSize(width: width, height: 250)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 15
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHistoryHeaderView, for: indexPath) as! HistoryHeaderView
      
      header.delegate = self
      header.tag = indexPath.section
      
      let createdDate = groupedMovies[indexPath.section].createdDate
      header.configureHistoryHeaderView(with: Date().formattedDate(date: createdDate))
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 45)
  }
}

//MARK: Delegate
extension HistoryViewController: ChooseButtonSessionDelegate {
  func chooseMovie(view: UIView) {
    guard let headerView = view as? HistoryHeaderView else { return }
    let sectionIndex = headerView.tag
    
    if headerView.isToggle {
      listChoose.insert(sectionIndex)
    } else {
      listChoose.remove(sectionIndex)
    }
  }
}
