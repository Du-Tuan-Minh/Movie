//
//  RealmManager.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import FirebaseFirestore
import RealmSwift
import UIKit

class RealmManager {
  static let shared = RealmManager()
  private let db = Firestore.firestore()
  private var notificationToken: NotificationToken?
  
  private init() {}
  
  // Sync single movie to Firestore
  func syncMovieToFirestore(movie: MovieModel) {
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
        print("Error saving movie to Firestore: \(error)")
      }
    }
    
    // Sync genres
    let genresCollection = db.collection("movies").document(movie.id).collection("genres")
    for genre in movie.genres {
      genresCollection.document(genre.id).setData([
        "title": genre.title
      ])
    }
    
    // Sync comments
    let commentsCollection = db.collection("movies").document(movie.id).collection("comments")
    for comment in movie.comments {
      commentsCollection.document(comment.id).setData([
        "content": comment.content,
        "author": comment.author,
        "createdAt": comment.createdAt
      ])
    }
    
    // Sync videoURLs
    let videoURLsCollection = db.collection("movies").document(movie.id).collection("videoURLs")
    for (index, url) in movie.videoURLs.enumerated() {
      videoURLsCollection.document("\(index)").setData([
        "url": url
      ])
    }
  }
  
  // Delete a movie from Firestore
  func deleteMovieFromFirestore(movieId: String) {
    db.collection("movies").document(movieId).delete { error in
      if let error = error {
        print("Error deleting movie from Firestore: \(error)")
      }
    }
  }
  
  // Sync all movies from Firestore to Realm
  func syncMoviesFromFirestore() {
    db.collection("movies").addSnapshotListener { [weak self] snapshot, error in
      guard self != nil else { return }
      guard let documents = snapshot?.documents else {
        return
      }
      
      let realm: Realm
      do {
        realm = try Realm()
      } catch {
        return
      }
      
      var moviesToUpdate: [MovieModel] = []
      let movieIdsInFirestore: Set<String> = Set(documents.map { $0.documentID })
      
      // Delete movies in Realm that are not present in Firestore
      let existingMovies = realm.objects(MovieModel.self)
      let moviesToDelete = existingMovies.filter { !movieIdsInFirestore.contains($0.id) }
      
      do {
        if !moviesToDelete.isEmpty {
          try realm.write {
            realm.delete(moviesToDelete)
          }
        }
      } catch {
        print("Error deleting movies from Realm: \(error)")
      }
      
      let dispatchGroup = DispatchGroup()
      
      for document in documents {
        dispatchGroup.enter()
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
        
        movie.genres.removeAll()
        movie.comments.removeAll()
        movie.videoURLs.removeAll()
        
        let innerGroup = DispatchGroup()
        
        // Sync genres
        innerGroup.enter()
        document.reference.collection("genres").getDocuments { genreSnapshot, error in
          defer { innerGroup.leave() }
          guard let genreDocs = genreSnapshot?.documents else { return }
          for genreDoc in genreDocs {
            let genre = GenersModel()
            genre.id = genreDoc.documentID
            genre.title = genreDoc.data()["title"] as? String ?? ""
            movie.genres.append(genre)
          }
        }
        
        // Sync comments
        innerGroup.enter()
        document.reference.collection("comments").getDocuments { commentSnapshot, error in
          defer { innerGroup.leave() }
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
        
        // Sync videoURLs
        innerGroup.enter()
        document.reference.collection("videoURLs").getDocuments { videoSnapshot, error in
          defer { innerGroup.leave() }
          guard let videoDocs = videoSnapshot?.documents else { return }
          for videoDoc in videoDocs {
            if let url = videoDoc.data()["url"] as? String {
              movie.videoURLs.append(url)
            }
          }
        }
        
        innerGroup.notify(queue: .main) {
          moviesToUpdate.append(movie)
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) {
        do {
          try realm.write {
            for movie in moviesToUpdate {
              realm.add(movie, update: .modified)
            }
          }
        } catch {
          print("Error updating Realm movies: \(error)")
        }
      }
    }
  }
  
  // Observe Realm changes and sync automatically to Firestore
  func observeRealmChangesAndSync() {
    do {
      let realm = try Realm()
      let movies = realm.objects(MovieModel.self)
      notificationToken = movies.observe { [weak self] changes in
        guard let self = self else { return }
        switch changes {
        case .initial:
          break
        case .update(let movies, let deletions, let insertions, let modifications):
          insertions.forEach { index in
            let movie = movies[index]
            self.syncMovieToFirestore(movie: movie)
          }
          modifications.forEach { index in
            let movie = movies[index]
            self.syncMovieToFirestore(movie: movie)
          }
          deletions.forEach { index in
            print("Phim bị xóa tại index: \(index). Xử lý xóa Firestore tách biệt.")
          }
        case .error(let error):
          print("Lỗi quan sát Realm: \(error)")
        }
      }
    } catch {
      print("Không thể quan sát thay đổi Realm: \(error)")
    }
  }
}
