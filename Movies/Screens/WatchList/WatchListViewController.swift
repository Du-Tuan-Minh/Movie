//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/3/25.
//

import UIKit
import RealmSwift

class WatchListViewController: UIViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  
  //variable
  final private let reuseIdentifier: String = "WatchlistCell"
  var watchlist: List<WatchlistModel>?
  var allMovies: [(movie: MovieModel, addedDate: Date)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    loadMovies()
  }
}

//MARK: setupView
extension WatchListViewController {
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
  }
  
  //MARK: test again
  private func loadMovies() {
    guard let watchlist = watchlist else { return }
    allMovies = watchlist.flatMap { watchlistItem in
      watchlistItem.movie.map { movie in
        (movie, watchlistItem.addedDate)
      }
    }
    tableView.reloadData()
  }
}


//MARK: TableView
extension WatchListViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allMovies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? WatchlistCell else { return UITableViewCell() }
    let movieItem = allMovies[indexPath.row]
    cell.configureWatchListCell(with: movieItem.movie, time: movieItem.addedDate)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var detailVC = DetailViewController()
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 170
  }
}
