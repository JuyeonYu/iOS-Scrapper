//
//  CacheManager.swift
//  scrapper
//
//  Created by  유 주연 on 7/29/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation

enum CacheType: String {
  case openLink
}

class CacheManager {
  
  
  static let shared = CacheManager()
  init() {
    
  }
  
  var dict: [AnyHashable: Any] = [:]
}
