//
//  FeedViewModel.swift
//  scrapper
//
//  Created by  유 주연 on 7/20/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation
import FirebaseFunctions
import SwiftSoup
import RealmSwift
import FirebaseAuth

class FeedViewModel: ObservableObject {
  let realm: Realm
  let functions: FirebaseFunctions.Functions = Functions.functions()
  @Published var refreshTime: String = ""
  @Published var newsList: [Item] = []
  @Published var isLogin: Bool = false
  @Published var isLoading: Bool = false

  init(realm: Realm) {
    self.realm = realm
      
//      functions.useEmulator(withHost: "127.0.0.1", port: 5001)
    
    if Auth.auth().currentUser == nil {
      isLogin = false
      return
    } else {
      isLogin = true
    }
    
    Task {
      await fetchFeed()
    }
  }
  func fetchFeed() async {
      print("x->1 \(Date().timeIntervalSince1970)")
      
      guard !isLoading else { return }
      await MainActor.run { self.isLoading = true }
      
      let keywords = await fetchKeywords()
    print("x->2 \(Date().timeIntervalSince1970)")
    
    let dict = ["version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, "keywords": keywords] as [String : Any]
    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return }
    guard let json = String(data: data, encoding: .utf8) else { return }
      
      guard let keywordsJson = keywords.toJson() else { return }
      
      do {
          let itemCombo = try await fetchFeedItems(with: json)
        print("x->3 \(Date().timeIntervalSince1970)")
        let items = itemCombo.flatMap({ $0.items })
          await MainActor.run {
            self.newsList = items
            
            print("x->5 \(items.count)")
            
              self.refreshTime = Date().formatted()
              self.isLoading = false
          }
          
          await fetchAndUpdateOgTags(for: items)
        print("x->4 \(Date().timeIntervalSince1970)")
      } catch {
          print("Error fetching feed: \(error)")
          await MainActor.run { self.isLoading = false }
      }
  }

  private func fetchKeywords() async -> [String] {
      let keywords: [String] = await MainActor.run {
          Array(realm.objects(KeywordRealm.self).map { $0.keyword })
      }
      return keywords
  }

  private func fetchFeedItems(with keywordsJson: String) async throws -> [ItemCombo] {
      let result = try await functions.httpsCallable("feed").call(keywordsJson)
    print("x->3-1 \(Date().timeIntervalSince1970)")
      guard let value = result.data as? String,
            let data = value.data(using: .utf8) else {
          throw NSError(domain: "FeedError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid feed data"])
      }
    print("x->3-2 \(Date().timeIntervalSince1970)")
      return try JSONDecoder().decode([ItemCombo].self, from: data)
  }

  private func fetchAndUpdateOgTags(for items: [Item]) async {
      let urls = items.compactMap { URL(string: $0.link) }
      await withTaskGroup(of: (Int, URL, (title: String?, desc: String?, ogImage: URL?)).self) { group in
          for (index, url) in urls.enumerated() {
              group.addTask {
                let (title, desc, ogImage) = await self.fetchOgTag(for: url)
                  return (index, url, (title, desc, ogImage))
              }
          }
          
          for await (index, _, ogTag) in group {
              await MainActor.run {
                self.newsList[index].ogImage = ogTag.ogImage
              }
          }
      }
  }
  func fetchFeed2() {
    let realm: Realm = try! Realm()
    let keywords: [String] = Array(realm.objects(KeywordRealm.self).map { $0.keyword })
    guard let keywordsJsonData = try? JSONEncoder().encode(keywords) else { return }
    guard let keywordsJson = String(data: keywordsJsonData, encoding: .utf8) else { return }
    
    functions.httpsCallable("feed").call(keywordsJson) { res, error in
      guard let value = res?.data as? String else { return }
      guard let data = value.data(using: .utf8) else { return }
      guard let strings = try? JSONDecoder().decode(([String]).self, from: data) else { return }
      let urls = strings.compactMap { URL(string: $0) }
      
      for url in urls {
        self.fetchOgTag2(for: url) { title, desc, image in
          DispatchQueue.main.async {
            self.newsList.append(.init(keyword: "", title: title ?? "제목 없음", originallink: "", link: "", itemDescription: desc ?? "내용 없음", pubDate: "", ogImage: image))
          }
        }
      }
    }
  }
  
  func fetchOgTag(for url: URL) async -> (String?, String?, URL?) {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let html = String(data: data, encoding: .utf8)
      let document = try SwiftSoup.parse(html ?? "")
      
      let ogTitle = try document.select("meta[property=og:title]").attr("content")
      let ogDescription = try document.select("meta[property=og:description]").attr("content")
      let ogImageString = try document.select("meta[property=og:image]").attr("content")
      let ogImage = URL(string: ogImageString)
      
      return (ogTitle, ogDescription, ogImage)
    } catch {
      return (nil, nil, nil)
    }
  }
  
  func fetchOgTag2(for url: URL, completion: @escaping (String?, String?, URL?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else { return }
      
      do {
        let html = String(data: data, encoding: .utf8)
        let document = try SwiftSoup.parse(html ?? "")
        
        let ogTitle = try document.select("meta[property=og:title]").attr("content")
        let ogDescription = try document.select("meta[property=og:description]").attr("content")
        let ogImage = try document.select("meta[property=og:image]").attr("content")
        
        completion(ogTitle, ogDescription, URL(string: ogImage))
      } catch {
        completion(nil, nil, nil)
      }
    }.resume()
  }
}

extension Array where Element == String {
    func toJson() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
