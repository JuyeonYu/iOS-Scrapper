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
    var title: String
    let urlString: String
    let publishTime: String
    
    init(title: String, urlString: String, publishTime: String) {
        if title.contains("&quot;") {
            self.title = title.replacingOccurrences(of: "&quot;", with: "\"")
        } else if title.contains("<b>") {
            self.title = title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        } else if title.contains("&lt;") {
            self.title = title.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
        } else {
            self.title = title
        }
           
        self.urlString = urlString
        self.publishTime = publishTime   
    }
}

class NewsRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var urlString: String = ""
    @objc dynamic var publishTime: String = ""
}
