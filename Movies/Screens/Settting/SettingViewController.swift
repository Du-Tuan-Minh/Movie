//
//  SettingViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit

class SettingViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  
  //variable
  final private let reuseIdentifier: String = "SettingCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }
  
  @IBAction func backTapped(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}

//MARK: setupView
extension SettingViewController {
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
  }
}

//MARK: TableView
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SettingCell else {
      return UITableViewCell()
    }
    let settingItem = SettingCellType.allCases[indexPath.row]
    cell.configuareSettingCell(with: settingItem.image, title: settingItem.rawValue)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
}
