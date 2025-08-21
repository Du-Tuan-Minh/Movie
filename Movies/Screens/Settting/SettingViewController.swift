//
//  SettingViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import FittedSheets

class SettingViewController: BaseViewController {
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var titleButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupView()
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
    case .aboutApp:
      let aboutAppVC = AboutAppViewController()
      navigationController?.pushViewController(aboutAppVC, animated: true)
    case .primaryPolicy:
      break
    case .feedBack:
      let feedbackVC = FeedbackViewController()
      let sheet = SheetViewController(controller: feedbackVC, sizes: [.percent(0.9)])
      sheet.hasBlurBackground = true
      sheet.cornerRadius = 20
      self.present(sheet, animated: true)
    case .appLanguage:
      let languageVC = LanguageBottomSheets()
      let sheet = SheetViewController(controller: languageVC, sizes: [.fixed(200)])
      sheet.hasBlurBackground = true
      sheet.cornerRadius = 20
      self.present(sheet, animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as? SettingCell else {
      return UITableViewCell()
    }
    let settingItem = SettingCellType.allCases[indexPath.row]
    cell.configuareSettingCell(with: settingItem.image, title: settingItem.title)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
}
