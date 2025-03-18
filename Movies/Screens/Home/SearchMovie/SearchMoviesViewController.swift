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
  @IBOutlet private weak var compareButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "SearchCell"
  private var movies: Results<MovieModel>!
  private var filteredMovies: Results<MovieModel>!
  private var selectsIndexs: Set<IndexPath> = []
  var searchModel: SearchModel = .searchTwo
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupsearchBar()
    setupCollectionView()
    movies = getMovies()
    filteredMovies = movies
  }
  
  private func setupView() {
    CAGradientLayer().addGradient(to: compareButton, colors: [UIColor(resource: .lightBlue), UIColor(resource: .violet)], startPoint:  CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  private func setupsearchBar() {
    searchView.delegate = self
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.allowsMultipleSelection = true
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
  }
  
  private func getMovies() -> Results<MovieModel> {
    return try! Realm().objects(MovieModel.self)
  }
  
  private func historyCompare(selectedMovies: [MovieModel]) {
    let realm = try! Realm()
    let history = ComparisonModel()
    try! realm.write {
      history.comparedMovies.append(objectsIn: selectedMovies)
      realm.add(history)
    }
  }
  
  @IBAction func compareTapped(_ sender: Any) {
    let compareVC = CompareMoviesViewController()
    
    switch searchModel {
    case .searchTwo:
      compareVC.compareModel = .compareTwo
    case .searchMore:
      compareVC.compareModel = .compareMore
    }
    
    let selectedMovies = selectsIndexs.map { filteredMovies[$0.row] }
    historyCompare(selectedMovies: selectedMovies)
    compareVC.selectedMovies = selectedMovies
    navigationController?.pushViewController(compareVC, animated: true)
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
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.frame.width - 10) / 2
    return CGSize(width: width, height: 250)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 30
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
}
