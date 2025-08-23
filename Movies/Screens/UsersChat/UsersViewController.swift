//
//  UsersViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 22/8/25.
//

import UIKit
import FirebaseAuth

class UsersViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  private var users: [UserModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    fetchUsers()
  }
  
  private func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    view.addSubview(tableView)
  }
  
  private func fetchUsers() {
    showLoadingIndicator()
    FirebaseManager.shared.fetchUsers { [weak self] users, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let users = users {
        self.users = users.filter { $0.id != Auth.auth().currentUser?.uid }
        self.tableView.reloadData()
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
    let user = users[indexPath.row]
    cell.textLabel?.text = user.username
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let user = users[indexPath.row]
    showAlert(title: "Options", message: "What would you like to do with \(user.username)?", onAction: {
      self.startChat(with: user)
    }, additionalActions: [
      UIAlertAction(title: "Send Friend Request", style: .default) { _ in
        self.sendFriendRequest(to: user)
      }
    ])
  }
  
  private func sendFriendRequest(to user: UserModel) {
    guard let currentUserID = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to send friend requests", onAction: {})
      return
    }
    
    showLoadingIndicator()
    guard let userId = user.id else { return }
    
    FirebaseManager.shared.sendFriendRequest(from: currentUserID, to: userId) { [weak self] error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else {
        self.showAlert(title: "Success", message: "Friend request sent to \(user.username)", onAction: {})
      }
    }
  }
  
  private func startChat(with user: UserModel) {
    guard let currentUserID = Auth.auth().currentUser?.uid else {
      showAlert(title: "Error", message: "You must be logged in to start a chat", onAction: {})
      return
    }
    guard let userId = user.id else { return }
    showLoadingIndicator()
    FirebaseManager.shared.createChat(user1: currentUserID, user2: userId) { [weak self] chatID, error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else if let chatID = chatID {
        let chatVC = ChatViewController(chatID: chatID, otherUserID: userId)
        self.pushViewController(view: chatVC)
      }
    }
  }
}
