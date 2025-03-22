//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import RealmSwift

class FolderWatchListViewController: UIViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  
  //variable
  final private let reuseIdentifier: String = "FolderCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    createBarButton()
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: setupView
extension FolderWatchListViewController {
  private func createBarButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "plus"),
      style: .plain,
      target: self,
      action: #selector(addNewFolderTapped)
    )
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
  }
}

//MARK: Realm
extension FolderWatchListViewController {
  func getListFolder() -> Results<WatchlistFolderModel> {
    return try! Realm().objects(WatchlistFolderModel.self)
  }
  
  @objc func addNewFolderTapped() {
    let newfolder = NewFolderPopUp()
    newfolder.modelStatus = .folderWatchlist
    newfolder.delegate = self
    newfolder.appear(sender: self)
  }
}

//MARK: CollectionView
extension FolderWatchListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return getListFolder().count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let watchListVC = WatchListViewController()
    watchListVC.watchlist = getListFolder()[indexPath.row].movies
    navigationController?.pushViewController(watchListVC, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FolderCell else {
      return UICollectionViewCell()
    }
    let title = getListFolder()[indexPath.row].title
    cell.configueFolderCell(with: title)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 10) / 2
    return CGSize(width: width, height: 170)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
}

extension FolderWatchListViewController: NewFolderPopUpDelegate {
  func didCreateNewFolder() {
    collectionView.reloadData()
  }
}
