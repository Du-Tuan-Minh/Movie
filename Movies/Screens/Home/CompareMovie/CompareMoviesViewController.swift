//
//  CompareMoviesViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 28/2/25.
//

import UIKit
import DropDown

class CompareMoviesViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var compareButton: UIButton!
  
  //variable
  var selectedMovies: [MovieModel] = []
  
//  let menu: DropDown = {
//    let menu = DropDown()
//    menu.dataSource = ["Delete", "Replace"]
//    
//    let images = [UIImage(systemName: "trash"), UIImage(systemName: "pencil")]
//    menu.cellNib = UINib(nibName: "selectDropDown", bundle: nil)
//    menu.customCellConfiguration = { index, title, cell in
//      guard let cell = cell as? selectDropDown else { return }
//      cell.configSelectDropDown(delete: images[index]!, deleteTitle: "Delete", replace: images[index]! , replaceTitle: "Replace")
//    }
//    return menu
//  }()
//  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("selectedMovies \(selectedMovies)")
    setupTableView()
    setupButton()
  }
  
  private func setupButton() {
    CAGradientLayer().addGradient(to: compareButton, colors: [UIColor(resource: .lightBlue), UIColor(resource: .violet)], startPoint:  CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: "CompareCell", bundle: nil), forCellReuseIdentifier: "CompareCell")
  }
  
  @IBAction func compareTapped(_ sender: Any) {
    var resultVC = ResultsViewController()
    resultVC.compareMovies = selectedMovies
    navigationController?.pushViewController(resultVC, animated: true)
  }
  
}

//MARK: TableView
extension CompareMoviesViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedMovies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompareCell") as? CompareCell else {
      return UITableViewCell()
    }
    
    cell.configureCompareCell(with: selectedMovies[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 120
  }

}
