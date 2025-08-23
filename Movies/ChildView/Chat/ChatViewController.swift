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

class ChatViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var messageTextField: UITextField!
  @IBOutlet private weak var sendButton: UIButton!
  
  private var messages: [Message] = []
  private var usernames: [String: String] = [:]
  var chatID: String
  var otherUserID: String
  
  init(chatID: String, otherUserID: String) {
    self.chatID = chatID
    self.otherUserID = otherUserID
    super.init(nibName: nil, bundle: nil)
  }
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    fetchUsernames()
    listenForMessages()
  }
  
  private func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
    
    messageTextField.borderStyle = .roundedRect
    
    // Keyboard handling
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func keyboardWillShow(notification: Notification) {
    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
      let keyboardHeight = keyboardFrame.height
      view.frame.origin.y = -keyboardHeight
    }
  }
  
  @objc private func keyboardWillHide(notification: Notification) {
    view.frame.origin.y = 0
  }
  
  private func fetchUsernames() {
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    
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
        self.title = "Chat with \(username)"
        self.tableView.reloadData()
      }
    }
  }
  
  private func listenForMessages() {
    FirebaseManager.shared.fetchMessages(chatID: chatID) { [weak self] messages, error in
      guard let self = self else { return }
      if let messages = messages {
        self.messages = messages
        self.tableView.reloadData()
        self.scrollToBottom()
      }
    }
  }
  
  private func scrollToBottom() {
    if messages.count > 0 {
      let indexPath = IndexPath(row: messages.count - 1, section: 0)
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
  }
  
  @IBAction func sendMessage(_ sender: Any) {
    guard let content = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          !content.isEmpty,
          let senderUID = Auth.auth().currentUser?.uid else {
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
        self.scrollToBottom()
      }
    }
  }
  
  // MARK: - UITableViewDataSource
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
