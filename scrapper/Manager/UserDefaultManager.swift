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
  
  static func setIsUser() {
    UserDefaults.standard.set(true, forKey: Constants.UserDefault.isUser)
  }
  
  static func getIsUser() -> Bool {
    return UserDefaults.standard.bool(forKey: Constants.UserDefault.isUser)
  }
  
  static func setSelectedBottomTabBarIndex(_ index: Int) {
    UserDefaults.standard.set(index, forKey: Constants.UserDefault.tabBarIndex)
  }
  
  static func getSelectedBottomTabBarIndex() -> Int {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.tabBarIndex)
  }
  
  static func addMaxKeywordCount() {
    UserDefaults.standard.set(getMaxKeywordCount() + 5, forKey: Constants.UserDefault.maxKeyword)
  }
  
  static func getMaxKeywordCount() -> Int {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.maxKeyword)
  }
  
  static func addMaxGroupCount() {
    UserDefaults.standard.set(getMaxGroupCount() + 3, forKey: Constants.UserDefault.maxGroup)
  }
  
  static func getMaxGroupCount() -> Int {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.maxGroup)
  }
  
  static func setMaxIssueShareCount(_ count: Int) {
    UserDefaults.standard.set(count, forKey: Constants.UserDefault.maxShare)
  }
  
  static func getMaxIssueShareCount() -> Int {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.maxShare)
  }
}
