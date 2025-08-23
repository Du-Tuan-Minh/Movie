//
//  HomeViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit

class HomeViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView() 
    navigationController?.isNavigationBarHidden = true
  }
}

//MARK: setupView
extension HomeViewController {
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: HomeCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
  }
}

//MARK: CollectionView
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return HomeCellType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let homeItem = HomeCellType.allCases[indexPath.row]
    let folderVC = FolderWatchListViewController()
    let searchVC = SearchMoviesViewController()
    let historyVC = HistoryViewController()
    
    switch homeItem {
    case .compareTwoMovies:
      searchVC.searchModel = .searchTwo
      searchVC.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(searchVC, animated: true)
    case .compareMovies:
      searchVC.searchModel = .searchMore
      searchVC.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(searchVC, animated: true)
    case .watchlist:
      folderVC.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(folderVC, animated: true)
    case .history:
      historyVC.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(historyVC, animated: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as? HomeCell else {
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
