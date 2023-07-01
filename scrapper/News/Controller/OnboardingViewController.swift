//
//  OnboardingViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
  let onboardItems: [OnboardingItem] = [.init(head: "첫번째 헤드", imageName: "doc.fill", foot: "첫번째 바텀"),
                                        .init(head: "두번째 헤드", imageName: "favorite.fill", foot: "두번째 바텀"),
                                        .init(head: "세번째 헤드", imageName: "volt.fill", foot: "세번째 바텀")]
  @IBOutlet weak var nextBtn: UIButton!
  
  
  var currentPage: Int = 0 {
          didSet {
              pageControl.currentPage = currentPage
              if currentPage == 2 {
                nextBtn.setTitle("시작", for: .normal)
                nextBtn.backgroundColor = UIColor(named: "theme")
                
              } else {
                nextBtn.setTitle("다음", for: .normal)
                nextBtn.backgroundColor = .lightGray
              }
          }
      }
  @IBAction func onNext(_ sender: Any) {
    if currentPage == 2 {
      let main = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainViewController")
      main.modalTransitionStyle = .crossDissolve
      main.modalPresentationStyle = .overFullScreen
      self.present(main, animated: true)
    } else {
        currentPage += 1
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

  }
  
  @IBOutlet weak var pageControl: UIPageControl!
  
  @IBOutlet weak var collectionView: UICollectionView!
  override func viewDidLoad() {
        super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.isPagingEnabled = true
    collectionView.register(UINib(nibName: "OnboardingCell", bundle: nil), forCellWithReuseIdentifier: "OnboardingCell")
    collectionView.showsHorizontalScrollIndicator = false
    }
}

extension OnboardingViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.frame.width
    currentPage = Int(scrollView.contentOffset.x / width)
  }
}

extension OnboardingViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    onboardItems.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
    
    cell.configure(item: onboardItems[indexPath.row])
    
    return cell
  }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: collectionView.frame.width, height: collectionView.frame.height)
  }
}



