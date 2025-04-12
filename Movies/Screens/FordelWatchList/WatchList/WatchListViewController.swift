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
    self.enableEdgePanBackGesture()
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
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
extension WatchListViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allMovies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? WatchlistCell else { return UITableViewCell() }
    let movieItem = allMovies[indexPath.row]
    cell.configureWatchListCell(with: movieItem.movie, time: movieItem.addedDate, tag: indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detailVC = DetailsViewController()
    detailVC.movie = allMovies[indexPath.row].movie
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 225
  }
  
  //  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
  //      let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
  //          guard let self = self else {
  //              completionHandler(false)
  //              return
  //          }
  //
  //          let movieToRemove = self.allMovies[indexPath.row].movie
  //
  //          do {
  //              let realm = try! Realm()
  //              try realm.write {
  //                  // Tìm tất cả WatchlistModel chứa movie này
  //                  let watchlistsContainingMovie = realm.objects(WatchlistModel.self).filter("ANY movie.id == %@", movieToRemove.id)
  //
  //                  // Xóa movie khỏi tất cả WatchlistModel liên quan
  //                  for watchlist in watchlistsContainingMovie {
  //                      if let index = watchlist.movie.index(where: { $0.id == movieToRemove.id }) {
  //                          watchlist.movie.remove(at: index)
  //                      }
  //                  }
  //              }
  //
  //              self.allMovies.remove(at: indexPath.row)
  //              tableView.deleteRows(at: [indexPath], with: .automatic)
  //              tableView.reloadData()
  //              completionHandler(true)
  //          } catch {
  //              print("Error deleting movie from watchlist: \(error)")
  //              completionHandler(false)
  //          }
  //      }
  //
  //      deleteAction.image = UIImage(systemName: "trash")
  //      deleteAction.backgroundColor = .red
  //      return UISwipeActionsConfiguration(actions: [deleteAction])
  //  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
      guard let self = self else {
        completionHandler(false)
        return
      }
      
      let movieToRemove = self.allMovies[indexPath.row].movie
      
      do {
        let realm = try Realm()
        try realm.write {
          if let watchlist = self.watchlist {
            for watchlistItem in watchlist {
              if let index = watchlistItem.movie.index(where: { $0.id == movieToRemove.id }) {
                watchlistItem.movie.remove(at: index)
              }
            }
          }
        }
        self.allMovies.removeAll { $0.movie.id == movieToRemove.id }
        tableView.reloadData()
        completionHandler(true)
      } catch {
        print("Error deleting movie from watchlist: \(error)")
        completionHandler(false)
      }
    }
    deleteAction.image = UIImage(systemName: "trash")
    deleteAction.backgroundColor = .red
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
