import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine

class FirebaseManager {
  static let shared = FirebaseManager()
  let db = Firestore.firestore()
  
  private init() {}
  
  // MARK: - Authentication
  func registerUser(email: String, password: String, username: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
      guard let uid = result?.user.uid else {
        completion(error)
        return
      }
      let user = UserModel(id: uid, email: email, role: 0, username: username, friends: [])
      do {
        try self.db.collection("users").document(uid).setData(from: user)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
  
  func registerGoogleUser(email: String, username: String, uid: String, completion: @escaping (Error?) -> Void) {
    let user = UserModel(id: uid, email: email, role: 0, username: username, friends: [])
    do {
      try db.collection("users").document(uid).setData(from: user) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      completion(error)
    }
  }
  
  func getUserRole(completion: @escaping (Int?) -> Void) {
    guard let uid = Auth.auth().currentUser?.uid else { return  }
    db.collection("users").document(uid).getDocument { snapshot, error in
      if let user = try? snapshot?.data(as: UserModel.self) {
        completion(user.role)
      } else {
        completion(nil)
      }
    }
  }
  
  func sendPasswordResetEmail(email: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().sendPasswordReset(withEmail: email) { error in
      completion(error)
    }
  }
  
  func confirmPasswordReset(oobCode: String, newPassword: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().confirmPasswordReset(withCode: oobCode, newPassword: newPassword) { error in
      completion(error)
    }
  }
  
  // MARK: - Users
  func fetchUsers(completion: @escaping ([UserModel]?, Error?) -> Void) {
    db.collection("users").getDocuments { snapshot, error in
      guard let documents = snapshot?.documents else {
        completion(nil, error)
        return
      }
      let users = documents.compactMap { try? $0.data(as: UserModel.self) }
      completion(users, nil)
    }
  }
  
  func fetchUsername(for uid: String, completion: @escaping (String?, Error?) -> Void) {
    db.collection("users").document(uid).getDocument { snapshot, error in
      if let user = try? snapshot?.data(as: UserModel.self) {
        completion(user.username, nil)
      } else {
        completion(nil, error)
      }
    }
  }
  
  // MARK: - Friend Requests
  func sendFriendRequest(from: String, to: String, completion: @escaping (Error?) -> Void) {
    let request = FriendRequest(from: from, to: to, status: "pending")
    do {
      try db.collection("friend_requests").addDocument(from: request) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func acceptFriendRequest(requestId: String, from: String, to: String, completion: @escaping (Error?) -> Void) {
    db.collection("friend_requests").document(requestId).updateData(["status": "accepted"]) { error in
      if let error = error {
        completion(error)
        return
      }
      self.db.collection("users").document(from).updateData(["friends": FieldValue.arrayUnion([to])])
      self.db.collection("users").document(to).updateData(["friends": FieldValue.arrayUnion([from])]) { error in
        completion(error)
      }
    }
  }
  
  // MARK: - Chat
  func sendMessage(chatID: String, message: Message, completion: @escaping (Error?) -> Void) {
    do {
      try db.collection("chats").document(chatID).collection("messages").addDocument(from: message) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func createChat(user1: String, user2: String, completion: @escaping (String?, Error?) -> Void) {
    let chatID = [user1, user2].sorted().joined(separator: "_")
    let chatData: [String: Any] = ["participants": [user1, user2]]
    db.collection("chats").document(chatID).setData(chatData) { error in
      completion(error == nil ? chatID : nil, error)
    }
  }
  
  func fetchMessages(chatID: String, completion: @escaping ([Message]?, Error?) -> Void) {
    db.collection("chats").document(chatID).collection("messages")
      .order(by: "timestamp")
      .getDocuments { snapshot, error in
        guard let documents = snapshot?.documents else {
          completion(nil, error)
          return
        }
        let messages = documents.compactMap { try? $0.data(as: Message.self) }
        completion(messages, nil)
      }
  }
  
  // MARK: - Watchlist
  func addToWatchlist(userId: String, movie: MovieModel, completion: @escaping (Error?) -> Void) {
    let watchlistItem = WatchlistItem(movie: movie, addedDate: Timestamp())
    do {
      try db.collection("users").document(userId).collection("watchlist").document(movie.id ?? UUID().uuidString).setData(from: watchlistItem) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func fetchWatchlist(userId: String, completion: @escaping ([(movie: MovieModel, addedDate: Date)]?, Error?) -> Void) {
    db.collection("users").document(userId).collection("watchlist")
      .order(by: "addedDate", descending: true)
      .getDocuments { snapshot, error in
        guard let documents = snapshot?.documents else {
          completion(nil, error)
          return
        }
        let watchlist = documents.compactMap { doc -> (movie: MovieModel, addedDate: Date)? in
          if let item = try? doc.data(as: WatchlistItem.self) {
            return (item.movie, item.addedDate.dateValue())
          }
          return nil
        }
        completion(watchlist, nil)
      }
  }
  
  func removeFromWatchlist(userId: String, movieId: String, completion: @escaping (Error?) -> Void) {
    db.collection("users").document(userId).collection("watchlist").document(movieId).delete { error in
      completion(error)
    }
  }
  
  // MARK: - Movies
  func saveMovie(movie: MovieModel, completion: @escaping (Error?) -> Void) {
    let docRef = db.collection("movies").document(movie.id ?? UUID().uuidString)
    do {
      try docRef.setData(from: movie) { error in
        completion(error)
      }
      
      // Save genres as subcollection
      let genresCollection = docRef.collection("genres")
      for genre in movie.genres {
        try? genresCollection.document(genre.id ?? UUID().uuidString).setData(from: genre)
      }
      
      // Save comments as subcollection
      let commentsCollection = docRef.collection("comments")
      for comment in movie.comments {
        try? commentsCollection.document(comment.id ?? UUID().uuidString).setData(from: comment)
      }
      
      // Save videoURLs as subcollection
      let videoURLsCollection = docRef.collection("videoURLs")
      for (index, url) in movie.videoURLs.enumerated() {
        videoURLsCollection.document("\(index)").setData(["url": url])
      }
    } catch {
      completion(error)
    }
  }
  
  func deleteMovie(movieId: String, completion: @escaping (Error?) -> Void) {
    db.collection("movies").document(movieId).delete { error in
      completion(error)
    }
  }
  
  func fetchMovies(completion: @escaping ([MovieModel]?, Error?) -> Void) {
    db.collection("movies").getDocuments { snapshot, error in
      guard let documents = snapshot?.documents else {
        completion(nil, error)
        return
      }
      
      var movies: [MovieModel] = []
      let dispatchGroup = DispatchGroup()
      
      for document in documents {
        dispatchGroup.enter()
        var movie = try? document.data(as: MovieModel.self)
        
        // Fetch genres
        document.reference.collection("genres").getDocuments { genreSnapshot, error in
          if let genreDocs = genreSnapshot?.documents {
            movie?.genres = genreDocs.compactMap { try? $0.data(as: GenersModel.self) }
          }
          
          // Fetch comments
          document.reference.collection("comments").getDocuments { commentSnapshot, error in
            if let commentDocs = commentSnapshot?.documents {
              movie?.comments = commentDocs.compactMap { try? $0.data(as: CommentModel.self) }
            }
            
            // Fetch videoURLs
            document.reference.collection("videoURLs").getDocuments { videoSnapshot, error in
              if let videoDocs = videoSnapshot?.documents {
                movie?.videoURLs = videoDocs.compactMap { $0.data()["url"] as? String }
              }
              if let movie = movie {
                movies.append(movie)
              }
              dispatchGroup.leave()
            }
          }
        }
      }
      
      dispatchGroup.notify(queue: .main) {
        completion(movies, nil)
      }
    }
  }
  
  // MARK: - Storage for PDFs
//  func uploadPDF(data: Data, forMovieId: String, completion: @escaping (String?, Error?) -> Void) {
//    let ref = storage.child("movies/\(forMovieId).pdf")
//    ref.putData(data, metadata: nil) { _, error in
//      if let error = error {
//        completion(nil, error)
//        return
//      }
//      ref.downloadURL { url, error in
//        completion(url?.absoluteString, error)
//      }
//    }
//  }
  
  func createWatchlistFolder(userId: String, title: String, completion: @escaping (Error?) -> Void) {
    let folder = WatchlistFolderModel(id: nil, title: title, movies: [], createdDate: Date())
    do {
      try db.collection("users").document(userId).collection("watchlist_folders").addDocument(from: folder) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func fetchWatchlistFolders(userId: String, completion: @escaping ([WatchlistFolderModel]?, Error?) -> Void) {
    db.collection("users").document(userId).collection("watchlist_folders")
      .order(by: "createdDate", descending: true)
      .getDocuments { snapshot, error in
        guard let documents = snapshot?.documents else {
          completion(nil, error)
          return
        }
        let folders = documents.compactMap { try? $0.data(as: WatchlistFolderModel.self) }
        completion(folders, nil)
      }
  }
  
  func renameWatchlistFolder(userId: String, folderId: String, newTitle: String, completion: @escaping (Error?) -> Void) {
    db.collection("users").document(userId).collection("watchlist_folders").document(folderId)
      .updateData(["title": newTitle]) { error in
        completion(error)
      }
  }
  
  func deleteWatchlistFolder(userId: String, folderId: String, completion: @escaping (Error?) -> Void) {
    // Delete folder (movies are not deleted from watchlist collection, as they are referenced by ID)
    db.collection("users").document(userId).collection("watchlist_folders").document(folderId).delete { error in
      completion(error)
    }
  }
  
  func fetchWatchlistFolderMovies(userId: String, folderId: String, completion: @escaping ([(movie: MovieModel, addedDate: Date)]?, Error?) -> Void) {
    // First, get the folder to access its movies array
    db.collection("users").document(userId).collection("watchlist_folders").document(folderId).getDocument { snapshot, error in
      guard let folder = try? snapshot?.data(as: WatchlistFolderModel.self) else {
        completion(nil, error)
        return
      }
      
      // Fetch watchlist items based on movies array (IDs)
      let watchlistRef = self.db.collection("users").document(userId).collection("watchlist")
      let dispatchGroup = DispatchGroup()
      var watchlistItems: [(movie: MovieModel, addedDate: Date)] = []
      
      for movieId in folder.movies {
        dispatchGroup.enter()
        watchlistRef.document(movieId).getDocument { docSnapshot, error in
          if let item = try? docSnapshot?.data(as: WatchlistItem.self) {
            watchlistItems.append((item.movie, item.addedDate.dateValue()))
          }
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) {
        completion(watchlistItems.sorted { $0.addedDate > $1.addedDate }, nil)
      }
    }
  }
  
  
  // FirebaseManager Additions
  
  func saveComparisonHistory(userId: String, movies: [MovieModel], compareModel: String, completion: @escaping (Error?) -> Void) {
    let history = ComparisonHistory(id: nil, movies: movies, createdDate: Timestamp(), compareModel: compareModel)
    do {
      try db.collection("users").document(userId).collection("comparison_history").addDocument(from: history) { error in
        completion(error)
      }
    } catch {
      completion(error)
    }
  }
  
  func clearTemporaryComparisons(userId: String, completion: @escaping (Error?) -> Void) {
    db.collection("users").document(userId).collection("temporary_comparisons").getDocuments { snapshot, error in
      guard let documents = snapshot?.documents else {
        completion(error)
        return
      }
      let batch = self.db.batch()
      for doc in documents {
        batch.deleteDocument(doc.reference)
      }
      batch.commit { error in
        completion(error)
      }
    }
  }
  
  enum FolderType {
    case watchlist
    case history
  }
  
  func addFolder<T: Codable>(userId: String, folder: T, type: FolderType, completion: @escaping (Error?) -> Void) {
    let collectionPath = type == .watchlist ? "watchlist_folders" : "history_folders"
    do {
      try db.collection("users").document(userId).collection(collectionPath).document((folder as? WatchlistFolderModel)?.id ?? (folder as? HistoryFolderModel)?.id ?? UUID().uuidString).setData(from: folder, completion: completion)
    } catch {
      completion(error)
    }
  }
}
