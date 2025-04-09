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
  @IBOutlet private weak var collectionView: UICollectionView!
  
  //variable
  final private let reuseIdentifier: String = "HomeCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    print(Realm.Configuration.defaultConfiguration.fileURL)
  }
}

//MARK: setupView
extension HomeViewController {
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
  }
}

//MARK: CollectionView
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return HomeCellType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let homeItem = HomeCellType.allCases[indexPath.row]
    let searchMoviesVC = SearchMoviesViewController()
    
    switch homeItem {
    case .compareTwoMovies:
      searchMoviesVC.searchModel = .searchTwo
      navigationController?.pushViewController(searchMoviesVC, animated: true)
    case .compareMovies:
      searchMoviesVC.searchModel = .searchMore
      navigationController?.pushViewController(searchMoviesVC, animated: true)
    case .watchlist:
      navigationController?.pushViewController(FolderWatchListViewController(), animated: true)
    case .history:
      navigationController?.pushViewController(HistoryViewController(), animated: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? HomeCell else {
      return UICollectionViewCell()
    }
    
    let homeItem = HomeCellType.allCases[indexPath.row]
    cell.configHomeCell(with: homeItem.image, title: homeItem.title)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let columns: CGFloat = 2
    
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      let totalSpacing = 50 * (columns - 1)
      let width = (collectionView.frame.width - totalSpacing) / columns
      return CGSize(width: width, height: 350)
    case .phone:
      let totalSpacing = 10 * (columns - 1)
      let width = (collectionView.frame.width - totalSpacing) / columns
      return CGSize(width: width, height: 220)
    default:
      let width = (collectionView.frame.width - 10) / 2
      return CGSize(width: width, height: 220)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 40
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
}
