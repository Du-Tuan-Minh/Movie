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
  
  //variable
  final private let reuseIdentifier: String = "FoodCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
  }
  
  private func getListFood() -> Results<FoodModel> {
    return try! Realm().objects(FoodModel.self)
  }
}

//MARK: CollectioView
extension FoodViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return getListFood().count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FoodCell else {
      return UICollectionViewCell()
    }
    cell.configureFoodCell(with: getListFood()[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width
    return CGSize(width: width, height: 150)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
}
