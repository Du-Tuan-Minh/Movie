//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 13/3/25.
//

import UIKit
import FirebaseAuth
import DropDown

class FolderWatchListViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  var selectedIndexPath: IndexPath?
  private var folders: [WatchlistFolderModel] = []
  
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
    loadFolders()
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
    collectionView.register(UINib(nibName: FolderCell.identifier, bundle: nil), forCellWithReuseIdentifier: FolderCell.identifier)
  }
  
  private func loadFolders() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to view folders", onAction: {})
      return
    }
    
    showLoadingIndicator()
    FirebaseManager.shared.fetchWatchlistFolders(userId: userId) { [weak self] folders, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let folders = folders {
        self.folders = folders
        self.collectionView.reloadData()
      }
    }
  }
}

//MARK: CollectionView
extension FolderWatchListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return folders.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to view watchlist", onAction: {})
      return
    }
    
    let watchListVC = WatchListViewController()
    let folder = folders[indexPath.row]
    
    showLoadingIndicator()
    FirebaseManager.shared.fetchWatchlistFolderMovies(userId: userId, folderId: folder.id ?? "") { [weak self] watchlist, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let watchlist = watchlist {
        watchListVC.allMovies = watchlist
        watchListVC.idFolder = folder.id
        self.navigationController?.pushViewController(watchListVC, animated: true)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.identifier, for: indexPath) as? FolderCell else {
      return UICollectionViewCell()
    }
    let folder = folders[indexPath.row]
    cell.configueFolderCell(with: folder.title)
    
    cell.didTapSelect = { [weak self] in
      guard let self = self else { return }
      let indexPath = collectionView.indexPath(for: cell) ?? IndexPath(item: 0, section: 0)
      self.selectedIndexPath = indexPath
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
    loadFolders()
  }
}

//MARK: DropDown
extension FolderWatchListViewController {
  func selectItemDropDown() {
    self.menu.selectionAction = { [weak self] (index, item) in
      guard let self = self, let selectedIndexPath = self.selectedIndexPath,
            let userId = Auth.auth().currentUser?.uid,
            let selectItem = ItemFolderDropDown(rawValue: item),
            let folderId = folders[selectedIndexPath.row].id else { return }
      
      switch selectItem {
      case .remove:
        showLoadingIndicator()
        FirebaseManager.shared.deleteWatchlistFolder(userId: userId, folderId: folderId) { [weak self] error in
          guard let self = self else { return }
          self.hideLoadingIndicator()
          if let error = error {
            self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
          } else {
            self.folders.remove(at: selectedIndexPath.row)
            self.collectionView.deleteItems(at: [selectedIndexPath])
          }
        }
      case .rename:
        // Tạo UIAlertController với text field
        let alert = UIAlertController(title: "Rename Folder", message: "Enter new folder name", preferredStyle: .alert)
        alert.addTextField { textField in
          textField.placeholder = "New folder name"
          textField.text = self.folders[selectedIndexPath.row].title
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
          guard let newName = alert.textFields?.first?.text, !newName.isEmpty else {
            self.showAlert(title: "Error", message: "Folder name cannot be empty", onAction: {})
            return
          }
          self.showLoadingIndicator()
          FirebaseManager.shared.renameWatchlistFolder(userId: userId, folderId: folderId, newTitle: newName) { [weak self] error in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            if let error = error {
              self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
            } else {
              self.folders[selectedIndexPath.row].title = newName
              self.collectionView.reloadItems(at: [selectedIndexPath])
            }
          }
        })
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
}
