//
//  Keyword.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import FirebaseAuth

struct Keyword: Codable {
  let keyword: String?
  let idx_keyword: Int?
}

class KeywordRealm: Object {
  @objc dynamic var keyword: String = ""
  @objc dynamic var exceptionKeyword: String = ""
  @objc dynamic var timestamp: TimeInterval = 0.0 // create_t
  @objc dynamic var lastReadTimestamp: TimeInterval = 0.0
  @objc dynamic var gourpId: UUID?
  @objc dynamic var notiEnabled: Bool = false
  @objc dynamic var hasNews: Bool = false

  
  var dict: [String: Any]? {
//    guard let userId = Auth.auth().currentUser?.uid else { return nil }
    return [
//      "user_id": userId,
      "keyword": keyword,
      "noti_enable": notiEnabled,
      "exception_keyword": exceptionKeyword,
      "last_read_t": lastReadTimestamp
    ]
  }
}

class GroupRealm: Object {
  @objc dynamic var name: String = ""
  @objc dynamic var id: UUID = .init()
  @objc dynamic var timestamp: TimeInterval = 0.0
}

class exceptNews: Object {
  @objc dynamic var press: String = ""
  @objc dynamic var domain: String = ""
}


struct KeywordFirestore {
  init(keywordRealm: KeywordRealm) {
    self.keyword = keywordRealm.keyword
    self.exceptKeyword = keywordRealm.exceptionKeyword.isEmpty ? nil : keywordRealm.exceptionKeyword
  }
  let keyword: String
  let notiEnable: Bool = false
  var userId: String? {
    Auth.auth().currentUser?.uid
  }
  let lastPushTime: Double = 0
  let exceptKeyword: String?
  
  
  var dict: [String: Any]? {
    guard let userId else { return nil }
    var dict: [String: Any] = [
      "user_id": userId,
      "keyword": keyword,
      "noti_enable": notiEnable,
      "last_push_time": lastPushTime,
    ]
    if let exceptKeyword {
      dict["except_keyword"] = exceptKeyword
    }
    return dict
  }
}
