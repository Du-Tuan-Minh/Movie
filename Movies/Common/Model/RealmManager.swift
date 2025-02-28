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
  @Persisted var duration: Int
  @Persisted var releaseDate: Date
  @Persisted var genres: List<String>
  @Persisted var userScore: Double
  @Persisted var budget: Double
  @Persisted var revenue: Double
  @Persisted var commentCount: Int
  @Persisted var comments: List<CommentModel>
}

//ComparisonModel
class ComparisonModel: Object {
  @Persisted(primaryKey: true) var id: String = UUID().uuidString
  @Persisted var comparedMovies: List<MovieModel>
  @Persisted var compareDate: Date
  @Persisted var filterCriteria: String
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
    @Persisted var movie: MovieModel?
    @Persisted var note: String
    @Persisted var addedDate: Date
}

//CommentModel
class CommentModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var movieID: String
    @Persisted var content: String
    @Persisted var author: String
    @Persisted var createdAt: Date
}
