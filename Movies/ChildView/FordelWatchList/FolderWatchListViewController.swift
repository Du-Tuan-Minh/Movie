//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import RealmSwift
import DropDown

class FolderWatchListViewController: BaseViewController {
  
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var titleButton: UIButton!
  //variable
  final private let reuseIdentifier: String = "FolderCell"
  var selectedIndexPath: IndexPath?
  
  //dropdown
  var menu: DropDown = {
    var menu = DropDown()
    menu.width = 250
    menu.dataSource = ItemFolderDropDown.allCases.map( \.rawValue )
    let images = [UIImage(systemName: "trash"), UIImage(systemName: "pencil")]
    
    menu.cellNib = UINib(nibName: "SelectCell", bundle: nil)
    menu.customCellConfiguration = { (index, title, cell) in
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
    setupCollectionView()
    selectItemDropDown()
    setupView()
  }
  
  @IBAction func addFolderTapped(_ sender: Any) {
    let newfolder = NewFolderPopUp()
    newfolder.modelStatus = .folderWatchlist
    newfolder.delegate = self
    newfolder.appear(sender: self)
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: setupView
extension FolderWatchListViewController {
  private func setupView() {
    titleButton.setTitle("watchlist".localized(), for: .normal)
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
  }
}

//MARK: Realm
extension FolderWatchListViewController {
  private func getListFolder() -> Results<WatchlistFolderModel> {
    return try! Realm().objects(WatchlistFolderModel.self)
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
    watchListVC.idFolder = getListFolder()[indexPath.row].id
    navigationController?.pushViewController(watchListVC, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FolderCell else {
      return UICollectionViewCell()
    }
    let title = getListFolder()[indexPath.row].title
    cell.configueFolderCell(with: title)
    
    cell.didTapSelect = { [weak self] in
      guard let self = self else { return }
      let indexpath = collectionView.indexPath(for: cell) ?? IndexPath(item: 0, section: 0)
      selectedIndexPath = indexpath
      self.menu.anchorView = cell
      self.menu.show()
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 30) / 2
    return CGSize(width: width, height: 170)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 30
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 15
  }
}

//MARK: Delegate
extension FolderWatchListViewController: NewFolderPopUpDelegate {
  func didCreateNewFolder() {
    collectionView.reloadData()
  }
}

//MARK: DropDown
extension FolderWatchListViewController {
  func selectItemDropDown() {
    self.menu.selectionAction = { [weak self] (index, item) in
      guard let self = self, let selectedIndexPath = self.selectedIndexPath else { return }
      guard let selectItem = ItemFolderDropDown(rawValue: item) else { return }
      
      let realm = try! Realm()
      let selectedFolder = getListFolder()[selectedIndexPath.row]
      
      switch selectItem {
      case .remove:
        try! realm.write {
          realm.delete(selectedFolder.movies)
          realm.delete(selectedFolder)
        }
        self.collectionView.reloadData()
      case .rename:
        let alert = UIAlertController(title: "rename_the_folder".localized(), message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
          textField.text = selectedFolder.title
        }
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "save".localized(), style: .default, handler: { _ in
          if let newName = alert.textFields?.first?.text, !newName.isEmpty {
            try! realm.write {
              selectedFolder.title = newName
            }
            self.collectionView.reloadData()
          }
        }))
        present(alert, animated: true, completion: nil)
      }
    }
  }
}
