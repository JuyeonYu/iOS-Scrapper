//
//  Keyword.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class Keyword: NSObject {
    let keyword: String
    let desc: String
    let publishDate: Date?
    let link: URL?
    let image: URL?
    
    init(keyword: String, desc: String, publishDate: Date?, link:URL?, image: URL?) {
        self.keyword = keyword
        self.desc = desc
        self.publishDate = publishDate
        self.link = link
        self.image = image
    }
}
