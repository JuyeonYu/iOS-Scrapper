//
//  KeychainHelper.swift
//  scrapper
//
//  Created by  유 주연 on 7/3/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation
import Security


enum KeychainKey: String {
  case fcmToken = "fcmToken"
  case firebaseAuthToken = "firebaseAuthToken"
}

class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary
        
        // 기존 데이터가 있으면 업데이트
        SecItemDelete(query)
        
        return SecItemAdd(query, nil)
    }
    
    func load(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    func delete(key: String) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        return SecItemDelete(query)
    }
}

extension KeychainHelper {
    func saveString(key: String, value: String) -> OSStatus {
        if let data = value.data(using: .utf8) {
            return save(key: key, data: data)
        }
        return errSecParam
    }
    
    func loadString(key: String) -> String? {
        if let data = load(key: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
