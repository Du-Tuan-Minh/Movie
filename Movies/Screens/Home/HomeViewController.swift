//
//  HomeViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import RealmSwift
class HomeViewController: UIViewController {
  
  //outlet
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
    
    let realm = try! Realm()
    print(Realm.Configuration.defaultConfiguration.fileURL)
  }
}

//MARK: setup
extension HomeViewController {
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: "HomeCell")
  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let homeItem = HomeCellType.allCases[indexPath.row]
    switch homeItem {
    case .compareTwoMovies:
      navigationController?.pushViewController(CompareMoviesViewController(), animated: true)
    case .compareMovies:
      navigationController?.pushViewController(SearchMoviesViewController(), animated: true)
    case .watchlist:
      navigationController?.pushViewController(WatchListViewController(), animated: true)
    case .history:
      navigationController?.pushViewController(HistoryViewController(), animated: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as? HomeCell else {
      return UICollectionViewCell()
    }
    
    let homeItem = HomeCellType.allCases[indexPath.row]
    cell.configHomeCell(with: homeItem.image, title: homeItem.title)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 10) / 2
    return CGSize(width: width, height: 220)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 30
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
}
