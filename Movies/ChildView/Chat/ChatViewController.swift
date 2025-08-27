//
//  ChatViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 14/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var messageTextField: UITextField!
  @IBOutlet private weak var sendButton: UIButton!
  
  private var messages: [Message] = []
  private var usernames: [String: String] = [:]
  var chatID: String?
  var otherUserID: String?
  private var listener: ListenerRegistration?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard chatID != nil, otherUserID != nil else {
      showAlert(title: "Error", message: "Invalid chat configuration", onAction: {
        self.navigationController?.popViewController(animated: true)
      })
      return
    }
    setupUI()
    fetchUsernames()
    getAllMessages()
  }
  
  deinit {
    listener?.remove()
    NotificationCenter.default.removeObserver(self)
  }
  
  private func setupUI() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
  }
  
  private func fetchUsernames() {
    guard let currentUserID = Auth.auth().currentUser?.uid, let otherUserID = otherUserID else { return }
    
    FirebaseManager.shared.fetchUsername(for: currentUserID) { [weak self] username, error in
      guard let self = self else { return }
      if let username = username {
        self.usernames[currentUserID] = username
        self.tableView.reloadData()
      }
    }
    
    FirebaseManager.shared.fetchUsername(for: otherUserID) { [weak self] username, error in
      guard let self = self else { return }
      if let username = username {
        self.usernames[otherUserID] = username
        self.title = "Chat \(username)"
        self.tableView.reloadData()
      }
    }
  }
  
  private func getAllMessages() {
    guard let chatID = chatID else { return }
    listener?.remove()
    
    listener = FirebaseManager.shared.db.collection("chats").document(chatID).collection("messages")
      .order(by: "timestamp")
      .addSnapshotListener { [weak self] snapshot, error in
        guard let self = self else { return }
        if let error = error { return }
        guard let documents = snapshot?.documents else { return }
        
        self.messages = documents.compactMap { try? $0.data(as: Message.self) }
        self.tableView.reloadData()
        self.scrollToBottom()
      }
  }
  
  private func scrollToBottom() {
    if messages.count > 0 {
      let indexPath = IndexPath(row: messages.count - 1, section: 0)
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
  
  // MARK: - Actions
  @IBAction func sendMessage(_ sender: Any) {
    guard let content = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty,
          let senderUID = Auth.auth().currentUser?.uid,
          let chatID = chatID else {
      showAlert(title: "Error", message: "Please enter a message", onAction: {})
      return
    }
    
    let message = Message(id: UUID().uuidString, senderUID: senderUID, content: content, timestamp: Timestamp())
    showLoadingIndicator()
    FirebaseManager.shared.sendMessage(chatID: chatID, message: message) { [weak self] error in
      guard let self = self else { return }
      self.hideLoadingIndicator()
      if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription, onAction: {})
      } else {
        self.messageTextField.text = ""
      }
    }
  }
}

// MARK: - UITableView
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
    let message = messages[indexPath.row]
    let username = usernames[message.senderUID] ?? message.senderUID
    cell.textLabel?.text = "\(username): \(message.content)"
    return cell
  }
}
