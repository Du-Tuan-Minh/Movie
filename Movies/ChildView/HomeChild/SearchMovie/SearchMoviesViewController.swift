//
//  SearchMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 2/3/25.
//

import UIKit
import RealmSwift

enum SearchModel {
  case searchTwo
  case searchMore
}

class SearchMoviesViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var searchView: UISearchBar!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "SearchCell"
  private var movies: Results<MovieModel>!
  private var filteredMovies: Results<MovieModel>!
  private var selectsIndexs: Set<IndexPath> = []
  var searchModel: SearchModel = .searchTwo
  var selectedMovies: [MovieModel] = []
  private var replaceIndexPaths: IndexPath?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    setupSearchBar()
    movies = getMovies()
    filteredMovies = movies
    setupView()
  }
}

//MARK: setupView
extension SearchMoviesViewController {
  private func setupView() {
    titleButton.setTitle("search".localized(), for: .normal)
    searchView.placeholder = "textHere".localized()
    self.enableEdgePanBackGesture()
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
    collectionView.allowsMultipleSelection = true
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterWrapper")
  }
  
  private func getMovies() -> Results<MovieModel> {
    return try! Realm().objects(MovieModel.self)
  }
  
  private func historyCompare(selectedMovies: [MovieModel]) {
    let realm = try! Realm()
    let compare = ComparisonModel()
    try! realm.write {
      compare.comparedMovies.append(objectsIn: selectedMovies)
      realm.add(compare)
    }
  }
}

//MARK: Action
extension SearchMoviesViewController {
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: SearchBar
extension SearchMoviesViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filteredMovies = movies
    } else if let year = Int(searchText) {
      filteredMovies = movies.filter("releaseYear == %d", year)
    } else {
      filteredMovies = movies.filter("title CONTAINS[c] %@", searchText)
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
    } else {
      switch searchModel {
      case .searchTwo:
        if selectsIndexs.count < 2 {
          selectsIndexs.insert(indexPath)
        }
      case .searchMore:
        if selectsIndexs.count < 10 {
          selectsIndexs.insert(indexPath)
        }
      }
    }
    if let cell = collectionView.cellForItem(at: indexPath) as? SearchCell {
      cell.isChooseCell(isStatus: selectsIndexs.contains(indexPath))
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SearchCell else {
      return UICollectionViewCell()
    }
    cell.configSearchCell(with: filteredMovies[indexPath.row])
    cell.isChooseCell(isStatus: selectsIndexs.contains(indexPath))
    cell.isReplaceCell(isStatus: replaceIndexPaths == indexPath)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 10) / 2
    return CGSize(width: width, height: 250)
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
    return CGSize(width: collectionView.frame.width, height: 60)
  }
}

//MARK: Delegate Dropdown
extension SearchMoviesViewController: CompareMovieDelegate {
  func backUploadMovies(movie: [MovieModel]) {
    selectedMovies = movie
    selectsIndexs = []
    for (index, movie) in filteredMovies.enumerated() {
      if selectedMovies.contains(movie) {
        selectsIndexs.insert(IndexPath(item: index, section: 0))
      }
    }
    self.collectionView.reloadData()
  }
  
  func replaceUploadMovies(_ index: Int) {
    guard index >= 0 && index < selectedMovies.count else { return }
    
    let movieToReplace = selectedMovies[index]
    guard let filteredIndex = filteredMovies.firstIndex(of: movieToReplace) else {
      return
    }
    
    let indexPath = IndexPath(row: filteredIndex, section: 0)
    
    DispatchQueue.main.async {
      if let replaceCell = self.collectionView.cellForItem(at: indexPath) as? SearchCell {
        replaceCell.isReplaceCell(isStatus: true)
      } else {
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        if let replaceCell = self.collectionView.cellForItem(at: indexPath) as? SearchCell {
          replaceCell.isReplaceCell(isStatus: true)
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
    navigationController?.pushViewController(compareVC, animated: true)
  }
}
