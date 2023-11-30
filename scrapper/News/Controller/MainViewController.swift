//
//  MainViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import SwiftRater

class MainViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UserDefaultManager.setIsUser()
    
    guard  UserDefaultManager.getLastOpen() > 0 else { return }
    if Date().timeIntervalSince1970 - 86400 > UserDefaultManager.getLastOpen() {
      DispatchQueue.main.async {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayViewController"), animated: true)
      }
    }
    do {
      UserDefaultManager.setLastOpen()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    selectedIndex = UserDefaultManager.getSelectedBottomTabBarIndex()
    
    SwiftRater.check()
  }
  
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let currentIndex = tabBar.items?.firstIndex(of: item) ?? 0
    UserDefaultManager.setSelectedBottomTabBarIndex(currentIndex)
    
  }

}
