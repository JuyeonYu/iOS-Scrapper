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
  
  static func setIsUser(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: Constants.UserDefault.isUser)
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
  
  static func addMaxKeywordCount(_ count: Int) {
    UserDefaults.standard.set(getMaxKeywordCount() + count, forKey: Constants.UserDefault.maxKeyword)
  }
  
  static func getMaxKeywordCount() -> Int {
    let max = UserDefaults.standard.integer(forKey: Constants.UserDefault.maxKeyword)
    return max == 0 ? 5 : max
  }
  
  static func addMaxGroupCount(_ count: Int) {
    UserDefaults.standard.set(getMaxGroupCount() + count, forKey: Constants.UserDefault.maxGroup)
  }
  
  static func getMaxGroupCount() -> Int {
    let max = UserDefaults.standard.integer(forKey: Constants.UserDefault.maxGroup)
    return max == 0 ? 3 : max
  }
  
  static func setMaxIssueShareCount(_ count: Int) {
    UserDefaults.standard.set(count, forKey: Constants.UserDefault.maxShare)
  }
  
  static func getMaxIssueShareCount() -> Int {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.maxShare)
  }
  
  static func getLastOpenDay() -> Int {
    UserDefaults.standard.integer(forKey: Constants.UserDefault.lastOpen)
  }
  
  static func setLastOpenDay()  {
    UserDefaults.standard.set(Date().day ?? 1, forKey: Constants.UserDefault.lastOpen)
  }
  
  static func setLastReadNewsOriginalLink(keyword: String, link: String) {
    UserDefaults.standard.set(link, forKey: keyword)
  }
  static func getLastReadNewsOriginalLink(keyword: String) -> String? {
    return UserDefaults.standard.string(forKey: keyword)
  }
}
