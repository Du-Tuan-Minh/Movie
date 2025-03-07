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
  @Persisted(primaryKey: true) var id: String
  @Persisted var title: String
  @Persisted var duration: Int
  @Persisted var releaseYear: Int
  @Persisted var genres: List<String>
  @Persisted var userScore: Double
  @Persisted var budget: Double
  @Persisted var revenue: Double
  @Persisted var pdfData: Data?
  
  override init() {
    super.init()
    self.id = UUID().uuidString
  }
}

//ComparisonModel
class ComparisonModel: Object {
  @Persisted(primaryKey: true) var id: String
  @Persisted var comparedMovies: List<MovieModel>
  @Persisted var compareDate: Date
  @Persisted var filterCriteria: String
  
  override init() {
    super.init()
    self.id = UUID().uuidString
  }
}

//HistoryFolderModel
class HistoryFolderModel: Object {
  @Persisted(primaryKey: true) var id: String
  @Persisted var folderName: String
  @Persisted var comparisons: List<ComparisonModel>
  @Persisted var createdDate: Date
  
  override init() {
    super.init()
    self.id = UUID().uuidString
  }
}

//WatchlistModel
class WatchlistModel: Object {
  @Persisted(primaryKey: true) var id: String
  @Persisted var movie: MovieModel?
  @Persisted var note: String
  @Persisted var addedDate: Date
  
  override init() {
    super.init()
    self.id = UUID().uuidString
  }
}

//CommentModel
class CommentModel: Object {
  @Persisted(primaryKey: true) var id: String
  @Persisted var movie: MovieModel?
  @Persisted var content: String
  @Persisted var author: String
  @Persisted var createdAt: Date
  
  override init() {
    super.init()
    self.id = UUID().uuidString
  }
}
