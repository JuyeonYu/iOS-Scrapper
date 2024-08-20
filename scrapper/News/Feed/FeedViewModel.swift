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
import SwiftLinkPreview

class FeedViewModel: ObservableObject {
  let slp = SwiftLinkPreview(session: URLSession.shared,
           workQueue: SwiftLinkPreview.defaultWorkQueue,
           responseQueue: DispatchQueue.main,
                 cache: DisabledCache.instance)
  let realm: Realm
  let functions: FirebaseFunctions.Functions = Functions.functions()
  @Published var refreshTime: String = ""
  @Published var newsList: [Item] = []
  @Published var isLogin: Bool = false
  @Published var isLoading: Bool = false
  @Published var isPro: Bool = true

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
      isPro = await IAPManager.isPro()
    }
  }
  func fetchFeed() async {
      print("x->1 \(Date().timeIntervalSince1970)")
      
      guard !isLoading else { return }
      await MainActor.run { self.isLoading = true }
      
      let keywords = await fetchKeywords()
    print("x->2 \(Date().timeIntervalSince1970)")
    
    let dict = [
        "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        "keywords": keywords] 
      as [String : Any]
    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return }
    guard let json = String(data: data, encoding: .utf8) else { return }
      
      guard let keywordsJson = keywords.toJson() else { return }
      
      do {
          let itemCombo = try await fetchFeedItems(with: json)
        print("x->3 \(Date().timeIntervalSince1970)")
        let items = itemCombo.flatMap({ $0.items })
          await MainActor.run {
            self.newsList = items
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

  private func fetchAndUpdateOgTags(
    for items: [Item]
  ) async {
    for (
      idx,
      item
    ) in items.enumerated() {
      let preview = slp.preview(
        item.link,
        onSuccess: {
          result in
          print(
            "\(result)"
          )
          if let image = result.image,
             let url = URL(
              string: image
             ) {
            self.newsList[idx].ogImage = url
          } else {
            print(123123)
          }
        },
        onError: {
          error in 
          print(
            "\(error)"
          )
        })
    }
  }
}

extension Array where Element == String {
    func toJson() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
