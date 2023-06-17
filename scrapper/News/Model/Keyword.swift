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

