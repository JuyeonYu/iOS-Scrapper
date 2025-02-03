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
  var itemDescription: String
  let urlString: String
  let publishTime: String
  let originalLink: String
  
  var publishTimestamp: TimeInterval? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // 네이버 api에서 넘어오는 시간 포멧
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    if let date = dateFormatter.date(from: publishTime) {
        return date.timeIntervalSince1970
    } else {
        return nil
    }
  }
  
  init(title: String, itemDescription: String, urlString: String, originalLink: String, publishTime: String) {
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
      self.itemDescription = itemDescription
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
