//
//  RealmManager.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import FirebaseFirestore
import RealmSwift
import UIKit

//MovieModel
class MovieModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
  @Persisted var describe: String
  @Persisted var duration: Int
  @Persisted var releaseYear: Date?
  @Persisted var genres: List<GenersModel>
  @Persisted var userScore: Double
  @Persisted var budget: Double
  @Persisted var revenue: Double
  @Persisted var pdfData: Data?
  @Persisted var comments: List<CommentModel>
  @Persisted var videoURL: String?
  @Persisted var videoURLs: List<String>
}

class GenersModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
}

//ComparisonModel
class ComparisonModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var comparedMovies: List<MovieModel>
  @Persisted var criteria: String
  @Persisted var compareDate: Date
}

//HistoryFolderModel
class HistoryFolderModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var folderName: String
  @Persisted var comparisons: List<MovieModel>
  @Persisted var createdDate: Date
}

//WatchlistModel
class WatchlistModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var movie: List<MovieModel>
  @Persisted var note: String
  @Persisted var addedDate: Date
}

//WatchlistFolderModel
class WatchlistFolderModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
  @Persisted var movies: List<WatchlistModel>
  @Persisted var createdDate: Date
}

//CommentModel
class CommentModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var content: String
  @Persisted var author: String
  @Persisted var createdAt: Date
}

//FoodModel
class FoodModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
  @Persisted var price: String
  @Persisted var pdfData: Data?
  @Persisted var describe: String
  @Persisted var userScore: Double
  @Persisted var total: Int
  @Persisted var typeFoods: List<TypeFoodModel>
}

class TypeFoodModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
}

//HistoryBuyFoodModel
class HistoryBuyFoodModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var food: List<FoodModel>
  @Persisted var createdAt: Date
}

class RealmManager {
    static let shared = RealmManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Đồng bộ MovieModel lên Firestore
    func syncMovieToFirestore(movie: MovieModel) {
        // Lưu thông tin chính của movie
        let movieData: [String: Any] = [
            "title": movie.title,
            "describe": movie.describe,
            "duration": movie.duration,
            "releaseYear": movie.releaseYear ?? NSNull(),
            "userScore": movie.userScore,
            "budget": movie.budget,
            "revenue": movie.revenue,
            "videoURL": movie.videoURL ?? NSNull()
        ]
        
        db.collection("movies").document(movie.id).setData(movieData) { error in
            if let error = error {
                print("Lỗi khi lưu movie lên Firestore: \(error)")
            }
        }
        
        // Đồng bộ genres
        let genresCollection = db.collection("movies").document(movie.id).collection("genres")
        for genre in movie.genres {
            genresCollection.document(genre.id).setData([
                "title": genre.title
            ])
        }
        
        // Đồng bộ comments
        let commentsCollection = db.collection("movies").document(movie.id).collection("comments")
        for comment in movie.comments {
            commentsCollection.document(comment.id).setData([
                "content": comment.content,
                "author": comment.author,
                "createdAt": comment.createdAt
            ])
        }
        
        // Đồng bộ videoURLs
        let videoURLsCollection = db.collection("movies").document(movie.id).collection("videoURLs")
        for (index, url) in movie.videoURLs.enumerated() {
            videoURLsCollection.document("\(index)").setData([
                "url": url
            ])
        }
    }
    
    // Gọi khi thêm movie vào Realm
    func addMovie(movie: MovieModel) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(movie)
            syncMovieToFirestore(movie: movie)
        }
    }
}

extension RealmManager {
    func syncMoviesFromFirestore() {
        db.collection("movies").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Lỗi khi lấy movies từ Firestore: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let realm = try! Realm()
            try! realm.write {
                for document in documents {
                    let data = document.data()
                    let movie = MovieModel()
                    movie.id = document.documentID
                    movie.title = data["title"] as? String ?? ""
                    movie.describe = data["describe"] as? String ?? ""
                    movie.duration = data["duration"] as? Int ?? 0
                    movie.releaseYear = (data["releaseYear"] as? Timestamp)?.dateValue()
                    movie.userScore = data["userScore"] as? Double ?? 0.0
                    movie.budget = data["budget"] as? Double ?? 0.0
                    movie.revenue = data["revenue"] as? Double ?? 0.0
                    movie.videoURL = data["videoURL"] as? String
                    
                    let dispatchGroup = DispatchGroup()
                    
                    // Đồng bộ genres
                    dispatchGroup.enter()
                    document.reference.collection("genres").getDocuments { genreSnapshot, error in
                        defer { dispatchGroup.leave() }
                        guard let genreDocs = genreSnapshot?.documents else { return }
                        for genreDoc in genreDocs {
                            let genre = GenersModel()
                            genre.id = genreDoc.documentID
                            genre.title = genreDoc.data()["title"] as? String ?? ""
                            movie.genres.append(genre)
                        }
                    }
                    
                    // Đồng bộ comments
                    dispatchGroup.enter()
                    document.reference.collection("comments").getDocuments { commentSnapshot, error in
                        defer { dispatchGroup.leave() }
                        guard let commentDocs = commentSnapshot?.documents else { return }
                        for commentDoc in commentDocs {
                            let comment = CommentModel()
                            comment.id = commentDoc.documentID
                            comment.content = commentDoc.data()["content"] as? String ?? ""
                            comment.author = commentDoc.data()["author"] as? String ?? ""
                            comment.createdAt = (commentDoc.data()["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                            movie.comments.append(comment)
                        }
                    }
                    
                    // Đồng bộ videoURLs
                    dispatchGroup.enter()
                    document.reference.collection("videoURLs").getDocuments { videoSnapshot, error in
                        defer { dispatchGroup.leave() }
                        guard let videoDocs = videoSnapshot?.documents else { return }
                        for videoDoc in videoDocs {
                            if let url = videoDoc.data()["url"] as? String {
                                movie.videoURLs.append(url)
                            }
                        }
                    }
                    
                    // Chờ tất cả subcollections tải xong
                    dispatchGroup.notify(queue: .main) {
                        try! realm.write {
                            realm.add(movie, update: .modified)
                        }
                    }
                }
            }
        }
    }
}

extension RealmManager {
    func syncAllMoviesToFirestore() {
        let realm = try! Realm()
        let movies = realm.objects(MovieModel.self)
        for movie in movies {
            syncMovieToFirestore(movie: movie)
        }
    }
}
