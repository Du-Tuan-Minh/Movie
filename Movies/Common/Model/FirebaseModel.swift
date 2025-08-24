//
//  FirebaseModel.swift
//  Movies
//
//  Created by DuTuanMinh on 21/8/25.
//

import FirebaseFirestoreSwift
import FirebaseFirestore
import UIKit

// Save user info to Firestore
struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var role: Int
    var username: String?
    var friends: [String]?  // Array UID
}

// MovieModel
struct MovieModel: Codable, Identifiable, Hashable, Equatable {
    @DocumentID var id: String?
    var title: String
    var describe: String
    var duration: Int
    var releaseYear: Date?
    var genres: [GenersModel]
    var userScore: Double
    var budget: Double
    var revenue: Double
    var imageURL: String?
    var comments: [CommentModel]
    var trailerURL: String?
    var videoURLs: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieModel, rhs: MovieModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct WatchlistItem: Codable {
  let movie: MovieModel
  let addedDate: Timestamp
}

struct GenersModel: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
}

struct ComparisonModel: Codable, Identifiable {
    @DocumentID var id: String?
    var comparedMovies: [String]  // Movie IDs
    var criteria: String
    var compareDate: Date
}

struct ComparisonHistory: Codable {
  @DocumentID var id: String?
  var movies: [MovieModel]
  var createdDate: Timestamp
  var compareModel: String // "compareTwo" or "compareMore"
}

struct HistoryFolderModel: Codable, Identifiable {
    @DocumentID var id: String?
    var folderName: String
    var comparisons: [String]  // Movie IDs
    var createdDate: Date
}

struct WatchlistModel: Codable, Identifiable {
    @DocumentID var id: String?
    var movie: [String]  //  Movie IDs
    var note: String
    var addedDate: Date
}

struct WatchlistFolderModel: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var movies: [String]  // Watchlist IDs
    var createdDate: Date
}

struct CommentModel: Codable, Identifiable {
    @DocumentID var id: String?
    var content: String
    var author: String
    var createdAt: Date
}

// Model cho Chat
struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var senderUID: String
    var content: String
    var timestamp: Timestamp
}

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var from: String  // UID người gửi
    var to: String    // UID người nhận
    var status: String  // "pending", "accepted", "rejected"
}
