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
    tabFrame.size.height = 470
    tabFrame.origin.y = view.frame.height - 470
    tabBar.frame = tabFrame
    tabBar.backgroundColor = UIColor(resource: .darkBlue)
    tabBar.tintColor = UIColor(resource: .lightBlue)
    tabBar.unselectedItemTintColor = .white
    tabBar.layer.cornerRadius = 15
  }
  
  private func configureTabbar() {
    let homeVC = HomeViewController()
    let chatVC = ChatViewController()
    let foodVC = FoodViewController()
    let settingVC = SettingViewController()
    
    homeVC.tabBarItem = UITabBarItem(title: "home".localized(), image: UIImage(resource: .home), selectedImage: nil)
    chatVC.tabBarItem = UITabBarItem(title: "chat".localized(), image: UIImage(resource: .message), selectedImage: nil)
    foodVC.tabBarItem = UITabBarItem(title: "food".localized(), image: UIImage(resource: .food), selectedImage: nil)
    settingVC.tabBarItem = UITabBarItem(title: "setting".localized(), image: UIImage(resource: .setting), selectedImage: nil)
    
    let homeNav = UINavigationController(rootViewController: homeVC)
    let chatNav = UINavigationController(rootViewController: chatVC)
    let foodNaV = UINavigationController(rootViewController: foodVC)
    let settingNav = UINavigationController(rootViewController: settingVC)
    
    viewControllers = [homeNav, chatNav, foodNaV, settingNav]
  }
}
