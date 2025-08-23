//
//  WatchListViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/3/25.
//

import UIKit
import FirebaseAuth

class WatchListViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
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
    tableView.register(UINib(nibName: WatchlistCell.identifier, bundle: nil), forCellReuseIdentifier: WatchlistCell.identifier)
  }
  
  //MARK: test again
  private func loadMovies() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to view your watchlist", onAction: {})
      return
    }
    
    showLoadingIndicator()
    FirebaseManager.shared.fetchWatchlist(userId: userId) { [weak self] watchlist, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let watchlist = watchlist {
        self.allMovies = watchlist
        self.tableView.reloadData()
      }
    }
  }
}

//MARK: TableView
extension WatchListViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allMovies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistCell.identifier) as? WatchlistCell else { return UITableViewCell() }
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
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
      guard let self = self, let userId = Auth.auth().currentUser?.uid else {
        completionHandler(false)
        return
      }
      
      let movieToRemove = self.allMovies[indexPath.row].movie
      showLoadingIndicator()
      FirebaseManager.shared.removeFromWatchlist(userId: userId, movieId: movieToRemove.id ?? "") { [weak self] error in
        guard let self = self else {
          completionHandler(false)
          return
        }
        self.hideLoadingIndicator()
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
          completionHandler(false)
        } else {
          self.allMovies.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .automatic)
          completionHandler(true)
        }
      }
    }
    deleteAction.image = UIImage(systemName: "trash")
    deleteAction.backgroundColor = .red
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}
