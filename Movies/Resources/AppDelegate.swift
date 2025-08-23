//
//  AppDelegate.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "195193469928-tumtq30cgoqrt7taebsgjc877u8c6a16.apps.googleusercontent.com")
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    // Handle Firebase password reset deep links
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let oobCode = components.queryItems?.first(where: { $0.name == "oobCode" })?.value {
      // Create ForgotPasswordViewController
      let vc = ForgotPasswordViewController()
      vc.mode = .reset
      vc.oobCode = oobCode
      // Navigate to ForgotPasswordViewController
      if let navigationController = window?.rootViewController as? UINavigationController {
        navigationController.pushViewController(vc, animated: true)
      } else {
        // Fallback: Present modally if no navigation controller
        window?.rootViewController?.present(vc, animated: true)
      }
      return true
    }
    return false
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}
