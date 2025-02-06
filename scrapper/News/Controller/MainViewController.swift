//
//  MainViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import SwiftRater
import SwiftUI

class MainViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UserDefaultManager.setIsUser(true)
    
//    viewControllers?.insert(UIHostingController(rootView: FeedView(onNews: { news in
//      guard let url = URL(string: news.link) else { return}
//      self.presentSafari(url: url)
//    })), at: 2)
      viewControllers?.insert(UIHostingController(rootView: BreakingNewsView(onNews: { news in
        guard let url = URL(string: news.link) else { return }
        self.presentSafari(url: url)
      })), at: 1)
    viewControllers?[1].tabBarItem.selectedImage = .init(systemName: "n.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.init(named: "Theme")!)
    viewControllers?[1].tabBarItem.image = .init(systemName: "n.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
    Task {
      if await !IAPManager.isPro() && UserDefaultManager.getLastOpenDay() != Date().day ?? 1 {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayViewController"), animated: true)
      }
      UserDefaultManager.setLastOpenDay()
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(CacheType.openLink.rawValue), object: nil, queue: nil) { notification in
      guard let link = notification.object as? URL else { return }
      UIViewController.topViewController()?.presentSafari(url: link)
      CacheManager.shared.dict[CacheType.openLink.rawValue] = nil
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    selectedIndex = UserDefaultManager.getSelectedBottomTabBarIndex()
    
    SwiftRater.check()
    
    if let link = CacheManager.shared.dict[CacheType.openLink.rawValue] as? URL {
      UIViewController.topViewController()?.presentSafari(url: link)
      CacheManager.shared.dict[CacheType.openLink.rawValue] = nil
      
    }
  }
  
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let currentIndex = tabBar.items?.firstIndex(of: item) ?? 0
    UserDefaultManager.setSelectedBottomTabBarIndex(currentIndex)
    
  }
  
}
