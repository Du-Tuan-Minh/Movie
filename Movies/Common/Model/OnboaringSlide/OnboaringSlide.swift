//
//  OnboaringSlide.swift
//  Movies
//
//  Created by DuTuanMinh on 12/4/25.
//

import UIKit

enum UserDefaultsKey {
  static let hasSeenOnboarding = "hasSeenOnboarding"
}

struct OnboaringSlide {
  var title: String
  var description: String
  var image: UIImage
}
