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
  let originalLink: String
  
  init(title: String, urlString: String, originalLink: String, publishTime: String) {
    // realm에 저장할때 '가 들어가면 filter로 값을 찾을 때 오류가 생김. '를 &squot; 바꿔 저장
    if title.contains("\'") {
      let temp1 = title.replacingOccurrences(of: "\'", with: "&squot;")
      self.title = temp1
    } else {
      self.title = title
    }
    self.originalLink = originalLink
    self.urlString = urlString
    self.publishTime = publishTime   
  }
}

class BookMarkNewsRealm: Object {
  @objc dynamic var title: String = ""
  @objc dynamic var urlString: String = ""
  @objc dynamic var publishTime: String = ""
}

class ReadNewsRealm: Object {
  @objc dynamic var title: String = ""
}
