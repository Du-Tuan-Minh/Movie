//
//  FoodViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 26/3/25.
//

import UIKit
import RealmSwift

class FoodViewController: UIViewController {
  
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var searchView: UISearchBar!
  @IBOutlet private weak var titleButton: UIButton!
  
  //variable
  final private let reuseIdentifier: String = "FoodCell"
  final private let TypeFoodreuseIdentifier: String = "TypeFoodCell"
  private var filterFood: Results<FoodModel>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    setupView()
    setupSearchBar()
    filterFood = getListFood()
  }
}

//MARK: SetupView
extension FoodViewController {
  private func setupView() {
    titleButton.setTitle("food".localized(), for: .normal)
    navigationController?.isNavigationBarHidden = true
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.register(UINib(nibName: TypeFoodreuseIdentifier, bundle: nil), forCellWithReuseIdentifier: TypeFoodreuseIdentifier)
    
    collectionView.collectionViewLayout = createCompositionalLayout()
    collectionView.alwaysBounceVertical = true
  }
  
  private func setupSearchBar() {
    searchView.searchTextField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchView.searchTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 16),
      searchView.searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -16),
      searchView.searchTextField.topAnchor.constraint(equalTo: searchView.topAnchor, constant: 0),
      searchView.searchTextField.bottomAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0),
      searchView.searchTextField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func getListFood() -> Results<FoodModel> {
    return try! Realm().objects(FoodModel.self)
  }
  
  private func getListTypeFood() -> Results<TypeFoodModel> {
    return try! Realm().objects(TypeFoodModel.self)
  }
}

//MARK: SearchBar
extension FoodViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filterFood = getListFood()
    } else {
      filterFood = getListFood().filter("title CONTAINS[c] %@", searchText)
    }
    collectionView.reloadData()
  }
}

//MARK: CompositionalLayout
extension FoodViewController {
  private func createCompositionalLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
      // Section 0: Horizontal
      if sectionIndex == 0 {
        return self.createHorizontalScrollSection()
      }
      // Section 1: Vertical
      else {
        return self.createVerticalScrollSection()
      }
    }
    
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 20
    layout.configuration = config
    return layout
  }
  
  private func createHorizontalScrollSection() -> NSCollectionLayoutSection {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(110), heightDimension: .absolute(40)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    // Group (horizontal)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(110), heightDimension: .absolute(40)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize, subitems: [item]
    )
    
    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 15, leading: 10, bottom: 15, trailing: 10
    )
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  private func createVerticalScrollSection() -> NSCollectionLayoutSection {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(200)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    // Group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize, subitem: item, count: 2
    )
    
    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 15
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: 10, bottom: 20, trailing: 10
    )
    return section
  }
}

// MARK: - UICollectionView
extension FoodViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? getListTypeFood().count : filterFood?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      let cell = collectionView.dequeueReusableCell( withReuseIdentifier: TypeFoodreuseIdentifier, for: indexPath ) as! TypeFoodCell
      cell.configure(with: getListTypeFood()[indexPath.item])
      return cell
    }
    else {
      let cell = collectionView.dequeueReusableCell( withReuseIdentifier: reuseIdentifier, for: indexPath ) as! FoodCell
      guard let filterFood = filterFood else { return cell }
      cell.configureFoodCell(with: filterFood[indexPath.item])
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      let selectType = getListTypeFood()[indexPath.item]
      filterFood = getListFood().filter("ANY typeFoods.id == %@", selectType.id)
      collectionView.reloadSections(IndexSet(integer: 1))
    } else {
      let detailVC = DetailFoodViewController()
      detailVC.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(detailVC, animated: true)
    }
  }
}
