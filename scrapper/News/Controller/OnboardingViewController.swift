//
//  OnboardingViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
  let onboardItems: [OnboardingItem] = [.init(head: "모든 뉴스를 다 볼 수는 없으니까", imageName: "onboarding1-1", foot: "관심있는 키워드를 등록해보세요!"),
                                        .init(head: "그룹으로 묶고, 즐겨찾고", imageName: "onboarding1-2", foot: "나만의 뉴스를 만들어보세요!"),
                                        .init(head: "요즘 뭐가 이슈인지", imageName: "onboarding1-3", foot: "뒤쳐지지 않게 만들어 드릴게요!")]
  @IBOutlet weak var nextBtn: UIButton!
  
  
  var currentPage: Int = 0 {
    didSet {
      pageControl.currentPage = currentPage
      if currentPage == 2 {
        nextBtn.setTitle("지금부터 시작", for: .normal)
        
        nextBtn.backgroundColor = UIColor(named: "Theme")
        
      } else {
        nextBtn.setTitle("다음", for: .normal)
        nextBtn.backgroundColor = UIColor(named: "Theme")?.withAlphaComponent(0.5)
      }
    }
  }
  @IBAction func onNext(_ sender: Any) {
    if currentPage == 2 {
      let payVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayViewController") as! PayViewController
      payVC.onClose = {
        let main = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
        main.modalTransitionStyle = .crossDissolve
        main.modalPresentationStyle = .overFullScreen
        self.present(main, animated: true)
      }
      self.present(payVC, animated: true)
      
      
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
    nextBtn.backgroundColor = .lightGray
    nextBtn.layer.cornerRadius = 20
    nextBtn.backgroundColor = UIColor(named: "Theme")?.withAlphaComponent(0.5)
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



