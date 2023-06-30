//
//  OnBoardingViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {
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
        print("go to main")
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
    
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OnBoardingViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.frame.width
    currentPage = Int(scrollView.contentOffset.x / width)
  }
}

extension OnBoardingViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    3
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath)
    if indexPath.row == 0 {
      
    } else if indexPath.row == 1 {
      
    } else {
      
    }
    return cell
  }
}

extension OnBoardingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    .init(width: collectionView.frame.width, height: collectionView.frame.height)
  }
}



