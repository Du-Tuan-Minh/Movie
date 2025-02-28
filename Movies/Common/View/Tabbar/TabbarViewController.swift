//
//  TabbarViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit

class TabbarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTabbar()
    configureTabbar()
  }
  
  private func setupTabbar() {
    tabBar.backgroundColor = UIColor(resource: .darkBlue)
    tabBar.tintColor = UIColor(resource: .lightBlue)
    tabBar.unselectedItemTintColor = .white
    tabBar.isTranslucent = false
  }
  
  private func configureTabbar() {
    let homeVC = HomeViewController()
    let watchListVC = WatchListViewController()
    let historyVC = HistoryViewController()
    let settingVC = SettingViewController()
    
    homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(resource: .home), selectedImage: nil)
    watchListVC.tabBarItem = UITabBarItem(title: "WatchList", image: UIImage(resource: .watchList), selectedImage: nil)
    historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(resource: .clock), selectedImage: nil)
    settingVC.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(resource: .setting), selectedImage: nil)
    
    let homeNav = UINavigationController(rootViewController: homeVC)
    let watchListNav = UINavigationController(rootViewController: watchListVC)
    let historyNav = UINavigationController(rootViewController: historyVC)
    let settingNav = UINavigationController(rootViewController: settingVC)
    
    viewControllers = [homeNav, watchListNav, historyNav, settingNav]
  }
}

