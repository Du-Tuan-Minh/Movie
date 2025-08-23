//
//  SearchMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 2/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum SearchModel {
  case searchTwo
  case searchMore
}

class SearchMoviesViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var searchView: UISearchBar!
  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var movedownButton: UIButton!
  
  //variable
  private var movies: [MovieModel] = []
  private var filteredMovies: [MovieModel] = []
  private var selectsIndexs: Set<IndexPath> = []
  var selectedMovies: [MovieModel] = []
  var searchModel: SearchModel = .searchTwo
  private var replaceIndexPaths: IndexPath?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    setupSearchBar()
    setupView()
    loadMovies()
  }
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

//MARK: setupView
extension SearchMoviesViewController {
  private func setupView() {
    titleButton.setTitle("search".localized(), for: .normal)
    searchView.placeholder = "textHere".localized()
  }
  
  private func setupSearchBar() {
    searchView.delegate = self
    searchView.searchTextField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchView.searchTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 0),
      searchView.searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: 0),
      searchView.searchTextField.topAnchor.constraint(equalTo: searchView.topAnchor, constant: 0),
      searchView.searchTextField.bottomAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0),
      searchView.searchTextField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: SearchCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchCell.identifier)
    collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterWrapper")
  }
  
  private func loadMovies() {
    showLoadingIndicator()
    FirebaseManager.shared.fetchMovies { [weak self] movies, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let movies = movies {
        self.movies = movies
        self.filteredMovies = movies
        self.collectionView.reloadData()
      }
    }
  }
  
  private func historyCompare(selectedMovies: [MovieModel]) {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to save comparisons", onAction: {})
      return
    }
    
    showLoadingIndicator()
    let dispatchGroup = DispatchGroup()
    var errors: [Error] = []
    
    for movie in selectedMovies {
      dispatchGroup.enter()
      let watchlistItem = FirebaseManager.WatchlistItem(movie: movie, addedDate: Timestamp())
      do {
        try FirebaseManager.shared.db.collection("users").document(userId).collection("temporary_comparisons").document(movie.id ?? UUID().uuidString).setData(from: watchlistItem) { error in
          if let error = error {
            errors.append(error)
          }
          dispatchGroup.leave()
        }
      } catch {
        errors.append(error)
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      self.hideLoadingIndicator()
      if !errors.isEmpty {
        self.showAlert(title: "Error", message: errors.first?.localizedDescription ?? "Failed to save comparisons", onAction: {})
      }
    }
  }
}

//MARK: Action
extension SearchMoviesViewController {
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func movedownTapped(_ sender: Any) {
    if filteredMovies.count > 0 {
      let lastIndexPath = IndexPath(item: filteredMovies.count - 1, section: 0)
      collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
    }
  }
}

//MARK: SearchBar
extension SearchMoviesViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filteredMovies = movies
    } else if let year = Int(searchText) {
      filteredMovies = movies.filter { movie in
        guard let releaseYear = movie.releaseYear else { return false }
        return Calendar.current.component(.year, from: releaseYear) == year
      }
    } else {
      filteredMovies = movies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    selectsIndexs = []
    for (index, movie) in filteredMovies.enumerated() {
      if selectedMovies.contains(where: { $0.id == movie.id }) {
        selectsIndexs.insert(IndexPath(item: index, section: 0))
      }
    }
    collectionView.reloadData()
  }
}

//MARK: CollectionView
extension SearchMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredMovies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.reloadItems(at: [indexPath])
    
    if selectsIndexs.contains(indexPath) {
      selectsIndexs.remove(indexPath)
      selectedMovies.removeAll { $0.id == filteredMovies[indexPath.row].id }
    } else {
      switch searchModel {
      case .searchTwo:
        if selectsIndexs.count < 2 {
          selectsIndexs.insert(indexPath)
          selectedMovies.append(filteredMovies[indexPath.row])
        }
      case .searchMore:
        if selectsIndexs.count < 10 {
          selectsIndexs.insert(indexPath)
          selectedMovies.append(filteredMovies[indexPath.row])
        }
      }
    }
    if let cell = collectionView.cellForItem(at: indexPath) as? SearchCell {
      cell.isChooseCell(isStatus: selectsIndexs.contains(indexPath))
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCell.identifier, for: indexPath) as? SearchCell else {
      return UICollectionViewCell()
    }
    cell.configSearchCell(with: filteredMovies[indexPath.row])
    cell.isChooseCell(isStatus: selectsIndexs.contains(indexPath))
    
    if let replaceIndexPaths = replaceIndexPaths , replaceIndexPaths == indexPath {
      cell.isReplaceCell()
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      let totalSpacing: CGFloat = 30
      let width = (collectionView.frame.width - totalSpacing) / 3
      return CGSize(width: width, height: 400)
    case .phone:
      let totalSpacing: CGFloat = 12
      let width = (collectionView.frame.width - totalSpacing) / 2
      return CGSize(width: width, height: 250)
    default:
      let width = (collectionView.frame.width - 10) / 2
      return CGSize(width: width, height: 250)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 50
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter {
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterWrapper", for: indexPath)
      
      footer.subviews.forEach { $0.removeFromSuperview() }
      if let footerCell = Bundle.main.loadNibNamed(FooterCell.identifier, owner: nil, options: nil)?.first as? FooterCell {
        footerCell.frame = footer.bounds
        footerCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        footerCell.delegate = self
        footerCell.titleButton = "next".localized()
        footer.addSubview(footerCell)
      }
      return footer
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      return CGSize(width: collectionView.frame.width, height: 360)
    case .phone:
      return CGSize(width: collectionView.frame.width, height: 60)
    default:
      return CGSize(width: collectionView.frame.width, height: 60)
    }
  }
}

//MARK: Delegate Dropdown
extension SearchMoviesViewController: CompareMovieDelegate {
  func backUploadMovies(movie: [MovieModel]) {
    selectedMovies = movie
    selectsIndexs = []
    for (index, movie) in filteredMovies.enumerated() {
      if selectedMovies.contains(where: { $0.id == movie.id }) {
        selectsIndexs.insert(IndexPath(item: index, section: 0))
      }
    }
    self.collectionView.reloadData()
  }
  
  func replaceUploadMovies(_ index: Int) {
    guard index >= 0 && index < selectedMovies.count else { return }
    
    let movieToReplace = selectedMovies[index]
    guard let filteredIndex = filteredMovies.firstIndex(where: { $0.id == movieToReplace.id }) else {
      return
    }
    
    let indexPath = IndexPath(row: filteredIndex, section: 0)
    
    DispatchQueue.main.async {
      if let replaceCell = self.collectionView.cellForItem(at: indexPath) as? SearchCell {
        replaceCell.isReplaceCell()
      } else {
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        if let replaceCell = self.collectionView.cellForItem(at: indexPath) as? SearchCell {
          replaceCell.isReplaceCell()
        }
      }
    }
    replaceIndexPaths = indexPath
    collectionView.reloadData()
  }
}

//MARK: Delegate footer
extension SearchMoviesViewController: FooterCellDelegate {
  func footerClick() {
    let compareVC = CompareMoviesViewController()
    compareVC.delegate = self
    
    switch searchModel {
    case .searchTwo:
      compareVC.compareModel = .compareTwo
    case .searchMore:
      compareVC.compareModel = .compareMore
    }
    selectedMovies = selectsIndexs.map { filteredMovies[$0.row] }
    historyCompare(selectedMovies: selectedMovies)
    compareVC.selectedMovies = selectedMovies
    if selectedMovies.count < 2 {
      showAlert(title: "can't_compare".localized(), message: "need_at_least_2_movies_to_compare".localized(), onAction: {})
    } else {
      replaceIndexPaths = nil
      collectionView.reloadData()
      navigationController?.pushViewController(compareVC, animated: true)
    }
  }
}
