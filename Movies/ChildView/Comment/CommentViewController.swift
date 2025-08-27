//
//  CommentViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 26/8/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var commentTextField: UITextField!
  @IBOutlet private weak var sendButton: UIButton!
  
  private var comments: [CommentModel] = []
  private var usernames: [String: String] = [:]
  private var listener: ListenerRegistration?
  var movie: MovieModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard movie != nil else {
      showAlert(title: "Error", message: "No movie data available", onAction: {
        self.dismiss(animated: true, completion: nil)
      })
      return
    }
    setupUI()
    fetchUsernames()
    getAllComments()
  }
  
  deinit {
    listener?.remove()
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    title = "Comments for \(movie?.title ?? "Movie")"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
  }
  
  // MARK: - Data Handling
  private func fetchUsernames() {
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    FirebaseManager.shared.fetchUsername(for: currentUserID) { [weak self] username, error in
      guard let self = self else { return }
      if let username = username {
        self.usernames[currentUserID] = username
        self.tableView.reloadData()
      }
    }
    
    let uniqueAuthorIDs = Set(comments.map { $0.author })
    for authorID in uniqueAuthorIDs {
      FirebaseManager.shared.fetchUsername(for: authorID) { [weak self] username, error in
        guard let self = self else { return }
        if let username = username {
          self.usernames[authorID] = username
          self.tableView.reloadData()
        }
      }
    }
  }
  
  private func getAllComments() {
    guard let movieID = movie?.id else { return }
    listener?.remove()
    
    listener = FirebaseManager.shared.db.collection("movies").document(movieID).collection("comments")
      .order(by: "createdAt")
      .addSnapshotListener { [weak self] snapshot, error in
        guard let self = self else { return }
        guard let documents = snapshot?.documents else { return }
        
        self.comments = documents.compactMap { try? $0.data(as: CommentModel.self) }
        self.fetchUsernames()
        self.tableView.reloadData()
        self.scrollToBottom()
      }
  }
  
  private func scrollToBottom() {
    if comments.count > 0 {
      let indexPath = IndexPath(row: comments.count - 1, section: 0)
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
  
  // MARK: - Actions
  @IBAction func sendComment(_ sender: Any) {
    guard let content = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty,
          let authorID = Auth.auth().currentUser?.uid,
          let movieID = movie?.id else {
      showAlert(title: "Error", message: "Please enter a comment", onAction: {})
      return
    }
    
    FirebaseManager.shared.fetchUsername(for: authorID) { [weak self] username, error in
      guard let self = self else { return }
      let author = username ?? authorID
      let comment = CommentModel(id: UUID().uuidString, content: content, author: author, createdAt: Date())
      
      self.showLoadingIndicator()
      FirebaseManager.shared.sendComment(movieID: movieID, comment: comment) { error in
        self.hideLoadingIndicator()
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
        } else {
          self.commentTextField.text = ""
        }
      }
    }
  }
}

// MARK: - UITableView
extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
    let comment = comments[indexPath.row]
    let username = usernames[comment.author] ?? comment.author
    let formattedDate = Date().formattedDate(date: comment.createdAt)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.text = "\(username) (\(formattedDate)): \(comment.content)"
    return cell
  }
}
