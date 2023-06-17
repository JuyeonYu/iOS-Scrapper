//
//  UserDefaultManager.swift
//  scrapper
//
//  Created by 주연  유 on 2020/09/08.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation

struct UserDefaultManager {
  static func setNewsOrder(order: String) {
    UserDefaults.standard.set(order, forKey: Constants.UserDefault.newsOrder)
  }
  
  static func getNewsOrder() -> String? {
    return UserDefaults.standard.string(forKey: Constants.UserDefault.newsOrder) ?? nil
  }
  
  static func setExclusivePress(_ isExclusive: Bool) {
    UserDefaults.standard.set(isExclusive, forKey: Constants.UserDefault.exclusivePress)
  }
  
  static func getExclusivePress() -> Bool {
    return UserDefaults.standard.bool(forKey: Constants.UserDefault.exclusivePress)
  }
  
}
