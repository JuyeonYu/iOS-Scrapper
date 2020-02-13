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
//    init(keyword: String, index: Int) {
//        self.keyword = keyword
//        self.idx_keyword = index
//    }
}

class KeywordRealm: Object {
    @objc dynamic var keyword: String = ""
}

