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
}
