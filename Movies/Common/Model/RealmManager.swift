//
//  RealmManager.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import RealmSwift
import UIKit

//MovieModel
class MovieModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var title: String
  @Persisted var describe: String
  @Persisted var duration: Int
  @Persisted var releaseYear: Int
  @Persisted var genres: List<String>
  @Persisted var userScore: Double
  @Persisted var budget: Double
  @Persisted var revenue: Double
  @Persisted var pdfData: Data?
  @Persisted var comments: List<CommentModel>
  @Persisted var videoURL: String?
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
  @Persisted var comparisons: List<ComparisonModel>
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
}

//HistoryBuyFoodModel
class HistoryBuyFoodModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var food: List<MovieModel>
  @Persisted var createdAt: Date
}
