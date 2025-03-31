//
//  Extension + Image.swift
//  Movies
//
//  Created by DuTuanMinh on 5/3/25.
//

import UIKit
import PDFKit

extension UIImage {
  static func convertPDFToImage(from data: Data) -> UIImage? {
    guard let document = PDFDocument(data: data),
          let page = document.page(at: 0) else { return nil }
    
    let pageRect = page.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    
    let image = renderer.image { ctx in
      UIColor.white.set()
      ctx.fill(pageRect)
      page.draw(with: .mediaBox, to: ctx.cgContext)
    }
    return image
  }
  
  //convertDateToImage
  func convertDateToImage(data: Data) -> UIImage? {
    var image = UIImageView().image
    if let pdfImage = UIImage.convertPDFToImage(from: data) {
      image = pdfImage
    } else {
      image = UIImage(named: "placeholder")
    }
    return image
  }
  
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
}
