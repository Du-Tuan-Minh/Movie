//
//  SceneDelegate.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  var coverView: UIView?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let screen = (scene as? UIWindowScene) else { return }
    let windowScreen = UIWindow(windowScene: screen)
    
    let hasSeenOnBoarding = UserDefaults.standard.bool(forKey: UserDefaultsKey.hasSeenOnboarding)
    
    if hasSeenOnBoarding {
      windowScreen.rootViewController = TabbarViewController()
    } else {
      windowScreen.rootViewController = OnboardingViewController()
    }
    
    windowScreen.makeKeyAndVisible()
    self.window = windowScreen
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    removeWhiteCoverView()
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    addWhiteCoverView()
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    removeWhiteCoverView()
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    addWhiteCoverView()
  }
  
  private func removeWhiteCoverView() {
    DispatchQueue.main.async { [weak self] in
      self?.coverView?.removeFromSuperview()
      self?.coverView = nil
    }
  }
  
  private func addWhiteCoverView() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, let window = self.window else { return }
      
      let whiteCover = UIView(frame: window.bounds)
      whiteCover.backgroundColor = .white
      
      window.addSubview(whiteCover)
      window.bringSubviewToFront(whiteCover)
      self.coverView = whiteCover
    }
  }
}
