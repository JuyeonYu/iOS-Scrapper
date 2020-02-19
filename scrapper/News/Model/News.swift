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
        if title.contains("&quot;") || title.contains("<b>") || title.contains("&lt;") {
            let temp1 = title.replacingOccurrences(of: "&quot;", with: "\"")
            let temp2 = temp1.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
            let temp3 = temp2.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
            self.title = temp3
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

class ReadNewsRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var urlString: String = ""
}
