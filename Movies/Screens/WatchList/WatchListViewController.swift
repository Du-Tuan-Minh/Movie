//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import RealmSwift

class WatchListViewController: UIViewController {
  
  @IBOutlet private weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
    createBarButton()
  }
  
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
    collectionView.register(UINib(nibName: "FolderCell", bundle: nil), forCellWithReuseIdentifier: "FolderCell")
  }
  
  func getListFolder() -> Results<WatchlistFolderModel> {
    return try! Realm().objects(WatchlistFolderModel.self)
  }
  
  @objc func addNewFolderTapped() {
    let newfolder = NewFolderPopUp()
    newfolder.delegate = self
    newfolder.appear(sender: self)
  }
  
}



//MARK: CollectionView
extension WatchListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return getListFolder().count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as? FolderCell else {
      return UICollectionViewCell()
    }
    var title = getListFolder()[indexPath.row].title
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

extension WatchListViewController: NewFolderPopUpDelegate {
  func didCreateNewFolder() {
    collectionView.reloadData()
  }
}
