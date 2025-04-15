//
//  UserDefaultKey.swift
//  Movies
//
//  Created by DuTuanMinh on 15/4/25.
//

import UIKit

class UserDefaultKey {
  static let shared = UserDefaultKey()
  
  let hasSeenOnboarding = "hasSeenOnboarding"
  let LocalizeUserDefaultKey = "LocalizeUser DefaultKey"

  var LocalizeDefaultLanguage: String {
    get {
      return UserDefaults.standard.string(forKey: LocalizeUserDefaultKey) ?? "en"
    }
    set {
      UserDefaults.standard.setValue(newValue, forKey: LocalizeUserDefaultKey)
    }
  }
}
