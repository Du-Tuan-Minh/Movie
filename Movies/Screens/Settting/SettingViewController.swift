//
//  SettingViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import FittedSheets
import FirebaseAuth

class SettingViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!
  @IBOutlet private weak var addMovieButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    FirebaseManager.shared.getUserRole { role in
      self.addMovieButton.isHidden = role != 1
    }
  }
  
  @IBAction func addMovie(_ sender: Any) {
    let addMovieVC = AddMovieViewController()
    self.navigationController?.pushViewController(addMovieVC, animated: true)
  }
}

//MARK: setupView
extension SettingViewController {
  private func setupView() {
    titleButton.setTitle("setting".localized(), for: .normal)
    navigationController?.isNavigationBarHidden = true
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: SettingCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SettingCell.reuseIdentifier)
  }
  
  private func presentSheet(with controller: UIViewController, size: SheetSize) {
    let sheet = SheetViewController(controller: controller, sizes: [size])
    sheet.hasBlurBackground = true
    sheet.cornerRadius = 20
    self.present(sheet, animated: true)
  }
}

//MARK: Action
extension SettingViewController {
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: TableView
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SettingCellType.allCases.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let listCell = SettingCellType.allCases[indexPath.row]
    switch listCell {
    case .feedBack:
      presentSheet(with: FeedbackViewController(), size: .percent(0.9))
    case .appLanguage:
      presentSheet(with: LanguageBottomSheets(), size: .fixed(200))
    case .logout:
      try! Auth.auth().signOut()
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as? SettingCell else {  return UITableViewCell() }
    let settingItem = SettingCellType.allCases[indexPath.row]
    cell.configuareSettingCell(with: settingItem.image, title: settingItem.title)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
}
