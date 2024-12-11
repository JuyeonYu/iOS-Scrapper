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

extension NaverNews {
    func groupByDay(items: [Item]) -> [[Item]] {
        var groupedItems: [[Item]] = []
        
        let sortedItems = items.sorted(by: { $0.createTimestamp > $1.createTimestamp })

        for item in sortedItems {
            if let lastGroup = groupedItems.last, lastGroup.first?.timeAgo == item.timeAgo {
                groupedItems[groupedItems.count - 1].append(item)
            } else {
                groupedItems.append([item])
            }
        }

        return groupedItems
    }
    
    var groupedItems: [[Item]] {
        var groupedItems: [[Item]] = []
        
        let polishedItems: [Item] = items.map {
            .init(
                keyword: $0.keyword,
                title: $0.title.replacingOccurrences(
                    of: "[<b>속보</b>] ",
                    with: ""
                ).replacingOccurrences(
                    of: "[<b>속보</b>]",
                    with: ""
                ),
                originallink: $0.originallink,
                link: $0.link,
                itemDescription: $0.itemDescription,
                pubDate: $0.pubDate
            )
        }
        
        // 속보는 최신순 정렬하기 때문에 본문에 속보 키워드가 들어간것도 포함시키면 너무 많아짐
        let filteredItems = polishedItems.filter { !$0.itemDescription.contains("속보") }
        let sortedItems = filteredItems.sorted(by: { $0.createTimestamp > $1.createTimestamp })
        
        for item in sortedItems {
            if let lastGroup = groupedItems.last, lastGroup.first?.timeAgo == item.timeAgo {
                groupedItems[groupedItems.count - 1].append(item)
            } else {
                groupedItems.append([item])
            }
        }
        return groupedItems
    }

}
// MARK: - Item
struct ItemCombo: Codable {
  let keyword: String?
  let items: [Item]
  
  enum CodingKeys: String, CodingKey {
    case keyword, items
  }
}

struct Item: Codable, Identifiable {
    var id: String {
        link
    }
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

extension Item {
    var createDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: pubDate)
    }
    
    var createTimestamp: TimeInterval {
        guard let date = createDate else {
            return 0
        }
        return date.timeIntervalSince1970
    }
    
    var timeAgo: String {
        guard let date = createDate else {
            return "Invalid Date"
        }
            
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        if timeInterval < 60 {
            return "최신"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)분 전"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)시간 전"
        } else if timeInterval < 2592000 {
            let days = Int(timeInterval / 86400)
            return "\(days)일 전"
        } else if timeInterval < 31536000 {
            let months = Int(timeInterval / 2592000)
            return "\(months)달 전"
        } else {
            let years = Int(timeInterval / 31536000)
            return "\(years)년 전"
        }

    }
}

//extension Item: Identifiable {
//  var id: UUID {
//    UUID()
//  }
//
////  var id: String {
////    link
////  }
////  var id: UUID = UUID()
//}
