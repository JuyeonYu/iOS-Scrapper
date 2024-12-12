//
//  IAPHelper.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/12.
//  Copyright © 2023 johnny. All rights reserved.
//

import Foundation

import StoreKit

final class IAPManager {
  static func isPro() async -> Bool {
      if forTest {
          return true
      }
      
    if #available(iOS 15.0, *) {
      for await result in Transaction.currentEntitlements {
        guard case .verified(let transaction) = result else {
          continue
        }
        
        if transaction.revocationDate == nil {
          return true
        } else {
          return false
        }
      }
    } else {
      return false
    }
    return false
  }
}
