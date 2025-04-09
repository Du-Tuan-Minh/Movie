//
//  HistoryViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  
  //variable
  final private let reuseIdentifier: String = "SearchCell"
  final private let reuseIdentifierHistoryHeaderView: String = "HistoryHeaderView"
  private var groupedMovies: [(createdDate: Date, movies: [MovieModel])] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadMovie()
    setupCollectionView()
  }
}

//MARK: setupView
extension HistoryViewController {
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
  
  private func loadMovie() {
    let historyList = getListHistory()
    groupedMovies = historyList.map { folder in
      (createdDate: folder.createdDate, movies: Array(folder.comparisons))
    }.sorted { $0.createdDate > $1.createdDate }
    collectionView.reloadData()
  }
}

//MARK: Action
extension HistoryViewController {
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cleanAllTapped(_ sender: Any) {
    self.showAlert(title: "do you want to delete everything", message: "") {
      let realm = try! Realm()
      try! realm.write {
        realm.delete(realm.objects(HistoryFolderModel.self))
        self.groupedMovies.removeAll()
        self.collectionView.reloadData()
      }
    }
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
    //    let detailVC = DetailsViewController()
    //    let selectedMovie = groupedMovies[indexPath.section].movies[indexPath.row]
    //    detailVC.movie = selectedMovie
    //    navigationController?.pushViewController(detailVC, animated: true)
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
    let width = (collectionView.frame.width - 10) / 3
    return CGSize(width: width, height: 235)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: reuseIdentifierHistoryHeaderView,
        for: indexPath) as! HistoryHeaderView
      
      let createdDate = groupedMovies[indexPath.section].createdDate
      header.dateLabel.text =  Date().formattedDate(date: createdDate)
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 45)
  }
}
