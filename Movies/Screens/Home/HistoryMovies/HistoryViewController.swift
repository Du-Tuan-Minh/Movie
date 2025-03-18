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
  var allMovies: [MovieModel] = []
  
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
  }
}

//MARK: Realm
extension HistoryViewController {
  private func getListHistory() -> Results<ComparisonModel> {
    return try! Realm().objects(ComparisonModel.self)
  }
  
  private func loadMovie() {
      let historyList = getListHistory()
      allMovies = historyList.flatMap { $0.comparedMovies }
      collectionView.reloadData()
  }
}

//MARK: CollectionView
extension HistoryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return getListHistory().count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = DetailViewController()
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SearchCell else {
      return UICollectionViewCell()
    }
    
    let movieItem = allMovies[indexPath.row]
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
}
