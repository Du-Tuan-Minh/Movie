//
//  Extension + Image.swift
//  Movies
//
//  Created by DuTuanMinh on 5/3/25.
//

import UIKit
import PDFKit

extension UIImage {
  static func convertDataToImage(from data: Data) -> UIImage? {
    if let document = PDFDocument(data: data), let page = document.page(at: 0) {
      let pageRect = page.bounds(for: .mediaBox)
      let scale: CGFloat = UIScreen.main.scale
      let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)
      
      let format = UIGraphicsImageRendererFormat()
      format.scale = scale
      format.opaque = false
      
      let renderer = UIGraphicsImageRenderer(size: scaledSize, format: format)
      
      let image = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(CGRect(origin: .zero, size: scaledSize))
        
        let context = ctx.cgContext
        context.saveGState()
        context.translateBy(x: 0, y: scaledSize.height)
        context.scaleBy(x: scale, y: -scale)
        
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
      }
      return image
    }
    if let image = UIImage(data: data) {
      return image
    }
    return nil
  }
  
  //convertDateToImage
  func convertDateToImage(data: Data) -> UIImage? {
    var image = UIImageView().image
    if let pdfImage = UIImage.convertDataToImage(from: data) {
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
