//
//  MainViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UserDefaultManager.setIsUser()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    selectedIndex = UserDefaultManager.getSelectedBottomTabBarIndex()
  }
  
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let currentIndex = tabBar.items?.firstIndex(of: item) ?? 0
    UserDefaultManager.setSelectedBottomTabBarIndex(currentIndex)
    
  }

}
