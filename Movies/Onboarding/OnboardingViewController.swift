//
//  OnboardingViewController.swift
//  Movies
//
//  Created by DuTuanMinh on 12/4/25.
//

import UIKit

class OnboardingViewController: UIViewController {
  //outlet
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var pageControl: UIPageControl!
  @IBOutlet private weak var nextButton: UIButton!
  
  //variable
  var slide: [OnboaringSlide] = []
  var currentPage = 0 {
    didSet {
      pageControl.currentPage = currentPage
      if currentPage == slide.count - 1 {
        nextButton.setTitle("Get Started", for: .normal)
      } else {
        nextButton.setTitle("Next", for: .normal)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    slide = inputDataSilde()
    setupCollectionView()
    setupView()
  }
  
  private func setupView() {
    CAGradientLayer().gradientButton(btn: nextButton)
  }
  
  private func inputDataSilde() -> [OnboaringSlide] {
    let slides: [OnboaringSlide] = [
      OnboaringSlide(title: "Discover a World of Movies", description: "Enjoy thousands of blockbusters, hit series, and exclusive content updated every day.", image: UIImage(resource: .onboarding1)),
      OnboaringSlide(title: "Smart Search, Easy Watching", description: "Quickly find movies by title, genre, actor, or community ratings.", image: UIImage(resource: .onboarding2)),
      OnboaringSlide(title: "Personalized for You", description: "Get movie recommendations based on your taste and save your favorites to watch anytime.", image: UIImage(resource: .onboarding3))]
    return slides
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    let nib = UINib(nibName: "OnboardingCell", bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: OnboardingCell.reuseIdentifier)
  }
  
  @IBAction func nextTapped(_ sender: Any) {
    if currentPage == slide.count - 1 {
      UserDefaults.standard.set(true, forKey: UserDefaultKey.shared.hasSeenOnboarding)
      
      let loginVC = LoginViewController()
      navigationController?.pushViewController(loginVC, animated: true)
    } else {
      currentPage += 1
      let indexPath = IndexPath(item: currentPage, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
  }
}

//MARK: UICollectionView
extension OnboardingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return slide.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.reuseIdentifier, for: indexPath) as? OnboardingCell else {
      return UICollectionViewCell()
    }
    cell.configureOnboardingCell(slide: slide[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let width = scrollView.frame.width
    currentPage = Int(scrollView.contentOffset.x / width)
  }
}
