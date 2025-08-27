//
//  Extension + Image.swift
//  Movies
//
//  Created by DuTuanMinh on 5/3/25.
//

import UIKit
import PDFKit

extension UIImage {
  // Star Rating
  func convertUseScoreToImage(movieScore: Double) -> UIImage {
    let score = max(0, min(4, Int(ceil(movieScore)) - 1))
    switch score {
    case 0: return UIImage(resource: .starOne)
    case 1: return UIImage(resource: .starTwo)
    case 2: return UIImage(resource: .starThree)
    case 3: return UIImage(resource: .starFour)
    case 4: return UIImage(resource: .starFive)
    default: return UIImage(resource: .starFive)
    }
  }
  
  func convertURLtoImage(movie: MovieModel?, movieImage: UIImageView) {
    guard let movie = movie else { return }
    
    let placeholderImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo") ?? UIImage()
    if let imageURL = movie.imageURL, let url = URL(string: imageURL) {
      URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
          DispatchQueue.main.async {
            movieImage.image = placeholderImage
          }
          return
        }
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            movieImage.image = image
          }
        } else {
          DispatchQueue.main.async {
            movieImage.image = placeholderImage
          }
        }
      }.resume()
    } else {
      movieImage.image = placeholderImage
    }
  }
}
