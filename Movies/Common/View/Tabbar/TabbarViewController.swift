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
    var tabFrame = tabBar.frame
    tabFrame.size.height = 450
    tabFrame.origin.y = view.frame.height - 450
    tabBar.frame = tabFrame
    tabBar.backgroundColor = UIColor(resource: .darkBlue)
    tabBar.tintColor = UIColor(resource: .lightBlue)
    tabBar.unselectedItemTintColor = .white
    tabBar.layer.cornerRadius = 15
  }
  
  private func configureTabbar() {
    let homeVC = HomeViewController()
    let watchListVC = FolderWatchListViewController()
    let foodVC = FoodViewController()
    let settingVC = SettingViewController()
    
    homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(resource: .home), selectedImage: nil)
    watchListVC.tabBarItem = UITabBarItem(title: "WatchList", image: UIImage(resource: .watchList), selectedImage: nil)
    foodVC.tabBarItem = UITabBarItem(title: "Food", image: UIImage(resource: .food), selectedImage: nil)
    settingVC.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(resource: .setting), selectedImage: nil)
    
    let homeNav = UINavigationController(rootViewController: homeVC)
    let watchListNav = UINavigationController(rootViewController: watchListVC)
    let foodNaV = UINavigationController(rootViewController: foodVC)
    let settingNav = UINavigationController(rootViewController: settingVC)
    
    viewControllers = [homeNav, watchListNav, foodNaV, settingNav]
  }
}
