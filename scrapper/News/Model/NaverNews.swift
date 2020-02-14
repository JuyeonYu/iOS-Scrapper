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
struct Item: Codable {
    let title: String
    let originallink: String
    let link: String
    let itemDescription, pubDate: String

    enum CodingKeys: String, CodingKey {
        case title, originallink, link
        case itemDescription = "description"
        case pubDate
    }
}
