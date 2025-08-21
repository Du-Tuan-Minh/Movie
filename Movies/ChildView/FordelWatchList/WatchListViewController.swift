//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/3/25.
//

import UIKit
import RealmSwift

class WatchListViewController: BaseViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "WatchlistCell"
  var watchlist: List<WatchlistModel>?
  var idFolder: String?
  var allMovies: [(movie: MovieModel, addedDate: Date)] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    loadMovies()
    setupView()
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: setupView
extension WatchListViewController {
  private func setupView() {
    titleButton.setTitle("my_list".localized(), for: .normal)
  }
  
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
    detailVC.modalPresentationStyle = .fullScreen
    present(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      return 400
    case .phone:
      return 225
    default:
      return 225
    }
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "delete".localized()) { [weak self] (_, _, completionHandler) in
      guard let self = self, let idFolder = idFolder else {
        completionHandler(false)
        return
      }
      let movieToRemove = self.allMovies[indexPath.row].movie
      
      do {
        let realm = try Realm()
        try realm.write {
          if let folder = realm.objects(WatchlistFolderModel.self).filter("id == %@", idFolder).first {
            for watchlistItem in folder.movies {
              if let index = watchlistItem.movie.index(where: { $0.id == movieToRemove.id }) {
                watchlistItem.movie.remove(at: index)
                if watchlistItem.movie.isEmpty {
                  realm.delete(watchlistItem)
                }
              }
            }
          }
        }
        self.allMovies.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        completionHandler(true)
      } catch {
        completionHandler(false)
      }
    }
    deleteAction.image = UIImage(systemName: "trash")
    deleteAction.backgroundColor = .red
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
