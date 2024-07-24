// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let naverNews = try? newJSONDecoder().decode(NaverNews.self, from: jsonData)

import Foundation

// MARK: - NaverNews
struct NaverNews: Codable {
  let lastBuildDate: String
  let total, start, display: Int
  let items: [Item]
}

// MARK: - Item
struct ItemCombo: Codable {
  let keyword: String?
  let items: [Item]
  
  enum CodingKeys: String, CodingKey {
    case keyword, items
  }
}

struct Item: Codable {
  let keyword: String?
  let title: String
  let originallink: String?
  let link: String
  let itemDescription, pubDate: String
  
  var ogImage: URL?
  
  enum CodingKeys: String, CodingKey {
    case title, originallink, link, keyword
    case itemDescription = "description"
    case pubDate
    case ogImage
  }
  
  var pubDateTimestamp: TimeInterval? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    if let date = dateFormatter.date(from: pubDate) {
        return date.timeIntervalSince1970
    } else {
        return nil
    }
  }
}

extension Item: Identifiable {
  var id: UUID {
    UUID()
  }
  
//  var id: String {
//    link
//  }
//  var id: UUID = UUID()
}
