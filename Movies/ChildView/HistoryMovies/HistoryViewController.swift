//
//  HistoryViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 12/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class HistoryViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "SearchCell"
  final private let reuseIdentifierHistoryHeaderView: String = "HistoryHeaderView"
  private var groupedMovies: [(createdDate: Date, movies: [MovieModel])] = []
  private var listChoose: IndexSet = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadMovie()
    setupView()
    setupCollectionView()
  }
}

//MARK: setupView
extension HistoryViewController {
  private func setupView() {
    titleButton.setTitle("history".localized(), for: .normal)
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    
    collectionView.register(
      UINib(nibName: reuseIdentifierHistoryHeaderView, bundle: nil),
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: reuseIdentifierHistoryHeaderView
    )
  }
}

//MARK: Realm
extension HistoryViewController {
  private func loadMovie() {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to view history", onAction: {})
      return
    }
    
    showLoadingIndicator()
    FirebaseManager.shared.db.collection("users").document(userId).collection("comparison_history").getDocuments { [weak self] snapshot, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        return
      }
      
      guard let documents = snapshot?.documents else { return }
      
      var moviesGroupedByDate = [Date: [MovieModel]]()
      for document in documents {
        if let history = try? document.data(as: FirebaseManager.ComparisonHistory.self) {
          let createdDate = history.createdDate.dateValue()
          let dateOnly = Calendar.current.startOfDay(for: createdDate)
          moviesGroupedByDate[dateOnly, default: []].append(contentsOf: history.movies)
        }
      }
      
      self.groupedMovies = moviesGroupedByDate.map { (date: Date, movies: [MovieModel]) in
        (createdDate: date, movies: movies)
      }.sorted { $0.createdDate > $1.createdDate }
      self.collectionView.reloadData()
    }
  }
}

//MARK: Action
extension HistoryViewController {
  @IBAction func deleteSessionTaped(_ sender: Any) {
    guard let userId = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to delete history", onAction: {})
      return
    }
    
    showLoadingIndicator()
    let db = FirebaseManager.shared.db.collection("users").document(userId).collection("comparison_history")
    
    if listChoose.isEmpty {
      showAlert(title: "Delete All History", message: "Do you want to delete everything?", onAction: {
        db.getDocuments { [weak self] snapshot, error in
          guard let self = self, let documents = snapshot?.documents else {
            self?.hideLoadingIndicator()
            self?.showAlert(title: "Error", message: error?.localizedDescription ?? "Failed to fetch history", onAction: {})
            return
          }
          
          let batch = FirebaseManager.shared.db.batch()
          for doc in documents {
            batch.deleteDocument(doc.reference)
          }
          batch.commit { error in
            self.hideLoadingIndicator()
            if let error = error {
              self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
            } else {
              self.groupedMovies.removeAll()
              self.collectionView.reloadData()
            }
          }
        }
      })
    } else {
      db.getDocuments { [weak self] snapshot, error in
        guard let self = self, let documents = snapshot?.documents else {
          self?.hideLoadingIndicator()
          self?.showAlert(title: "Error", message: error?.localizedDescription ?? "Failed to fetch history", onAction: {})
          return
        }
        
        let datesToDelete = self.listChoose.map { self.groupedMovies[$0].createdDate }
        let batch = FirebaseManager.shared.db.batch()
        
        for doc in documents {
          if let history = try? doc.data(as: FirebaseManager.ComparisonHistory.self) {
            let createdDate = history.createdDate.dateValue()
            if datesToDelete.contains(Calendar.current.startOfDay(for: createdDate)) {
              batch.deleteDocument(doc.reference)
            }
          }
        }
        
        batch.commit { error in
          self.hideLoadingIndicator()
          if let error = error {
            self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
          } else {
            for index in self.listChoose.sorted(by: >) {
              self.groupedMovies.remove(at: index)
            }
            self.listChoose.removeAll()
            self.collectionView.reloadData()
          }
        }
      }
    }
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: CollectionView
extension HistoryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return groupedMovies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return groupedMovies[section].movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let detailVC = DetailsViewController()
    let selectedMovie = groupedMovies[indexPath.section].movies[indexPath.row]
    detailVC.movie = selectedMovie
    detailVC.modalPresentationStyle = .fullScreen
    present(detailVC, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SearchCell else {
      return UICollectionViewCell()
    }
    let movieItem = groupedMovies[indexPath.section].movies[indexPath.row]
    cell.configSearchCell(with: movieItem)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      let totalSpacing: CGFloat = 100
      let width = (collectionView.frame.width - totalSpacing) / 3
      return CGSize(width: width, height: 400)
    case .phone:
      let totalSpacing: CGFloat = 10
      let width = (collectionView.frame.width - totalSpacing) / 3
      return CGSize(width: width, height: 250)
    default:
      let width = (collectionView.frame.width - 10) / 2
      return CGSize(width: width, height: 250)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 15
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHistoryHeaderView, for: indexPath) as! HistoryHeaderView
      
      header.delegate = self
      header.tag = indexPath.section
      
      let createdDate = groupedMovies[indexPath.section].createdDate
      header.configureHistoryHeaderView(with: Date().formattedDate(date: createdDate))
      return header
    }
    return UICollectionReusableView()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 45)
  }
}

//MARK: Delegate
extension HistoryViewController: ChooseButtonSessionDelegate {
  func chooseMovie(view: UIView) {
    guard let headerView = view as? HistoryHeaderView else { return }
    let sectionIndex = headerView.tag
    
    if headerView.isToggle {
      listChoose.insert(sectionIndex)
    } else {
      listChoose.remove(sectionIndex)
    }
  }
}
