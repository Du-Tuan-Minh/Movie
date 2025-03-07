//
//  SearchMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 2/3/25.
//

import UIKit
import RealmSwift

enum searchMode {
  case twoMovies
  case moreThanTwoMovies
}

class SearchMoviesViewController: UIViewController {
  
  //outlet
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchView: UISearchBar!
  @IBOutlet weak var compareButton: UIButton!
  
  //variable
  private var movies: Results<MovieModel>!
  private var filteredMovies: Results<MovieModel>!
  private var selectsIndexs: Set<IndexPath> = []
  
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
    collectionView.register(UINib(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: "SearchCell")
  }
  
  func getMovies() -> Results<MovieModel> {
    return try! Realm().objects(MovieModel.self)
  }
  
  @IBAction func compareTapped(_ sender: Any) {
    let selectedMovies = selectsIndexs.map { filteredMovies[$0.row] }
    let compareVC = CompareMoviesViewController()
    compareVC.selectedMovies = selectedMovies
    navigationController?.pushViewController(compareVC, animated: true)
  }
}

//MARK: SearchBar
extension SearchMoviesViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filteredMovies = movies
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
    if selectsIndexs.contains(indexPath) {
      selectsIndexs.remove(indexPath)
    } else {
      selectsIndexs.insert(indexPath)
    }
    collectionView.reloadItems(at: [indexPath])
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
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
