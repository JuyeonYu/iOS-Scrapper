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
    @objc dynamic var latestNewsTime: String?
    @objc dynamic var alarmTime: String?
    @objc dynamic var userID: String?
}

