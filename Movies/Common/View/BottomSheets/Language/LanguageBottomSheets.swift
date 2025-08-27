//
//  LanguageBottomSheets.swift
//  Movies
//
//  Created by DuTuanMinh on 15/4/25.
//

import UIKit

class LanguageBottomSheets: BaseViewController {
  //outlet
  @IBOutlet private weak var englishButton: UIButton!
  @IBOutlet private weak var vietButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
  }
  
  private func updateUI() {
    englishButton.setTitle("English".localized(), for: .normal)
    vietButton.setTitle("Vietnamese".localized(), for: .normal)
  }
  
  private func reloadAppLanguage() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate,
          let window = delegate.window else { return }
    
    let tabbarVC = TabbarViewController()
    window.rootViewController = tabbarVC
    window.makeKeyAndVisible()
  }
  
  @IBAction func englishTapped(_ sender: Any) {
    UserDefaultKey.shared.LocalizeDefaultLanguage = "en"
    reloadAppLanguage()
  }
  
  @IBAction func vietTapped(_ sender: Any) {
    UserDefaultKey.shared.LocalizeDefaultLanguage = "vi"
    reloadAppLanguage()
  }
}
