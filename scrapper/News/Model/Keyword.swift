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
  @objc dynamic var timestamp: TimeInterval = 0.0
  @objc dynamic var gourpId: UUID?
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
  }
  let keyword: String
  let notiEnable: Bool = true
  var userId: String? {
    Auth.auth().currentUser?.uid
  }
  let lastPushTime: Double = 0
  
  
  var dict: [String: Any]? {
    guard let userId else { return nil }
    return [
      "user_id": userId,
      "keyword": keyword,
      "noti_enable": notiEnable,
      "last_push_time": lastPushTime
    ]
  }
}
