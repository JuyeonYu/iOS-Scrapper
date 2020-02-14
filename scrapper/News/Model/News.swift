//
//  News.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class News: Codable {
    let title: String
    let urlString: String
    
    init(title: String, urlString: String) {
        self.title = title
        self.urlString = urlString
    }
}

class NewsRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var urlString: String = ""
}
