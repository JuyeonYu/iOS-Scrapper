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
  
  init(realm: Realm) {
    self.realm = realm
    
    if Auth.auth().currentUser == nil {
      isLogin = false
      return
    } else {
      isLogin = true
    }
    
    
    functions.useEmulator(withHost: "127.0.0.1", port: 5001)
    
    Task {
      
      await fetchFeed()
    }
    //      fetchFeed()
  }
  func fetchFeed() async {
    let keywords: [String]
    keywords = await MainActor.run {
      Array(realm.objects(KeywordRealm.self).map { $0.keyword })
    }
    
    guard let keywordsJsonData = try? JSONEncoder().encode(keywords) else { return }
    guard let keywordsJson = String(data: keywordsJsonData, encoding: .utf8) else { return }
    
    do {
      let result = try await functions.httpsCallable("feed").call(keywordsJson)
      guard let value = result.data as? String else { return }
      guard let data = value.data(using: .utf8) else { return }
      guard let items = try? JSONDecoder().decode([Item].self, from: data) else { return }
      await MainActor.run {
        self.newsList = items
      }
      
      
      //        for (index, news)  in self.newsList.enumerated() {
      //          DispatchQueue.main.async {
      //              self.newsList[index].ogImage = .init(string: "https://velog.velcdn.com/images/vaping_ape/post/24b6609d-7dc2-405d-a89a-f2133fc4ee16/image.jpg")!
      //            }
      //        }
      let urls = items.compactMap { URL(string: $0.link) }
      
      for (index, url) in urls.enumerated() {
        await fetchOgTag(for: url) { title, desc, ogImage in
          
          Task {
            await MainActor.run {
              self.newsList[index].ogImage = ogImage
            }
          }
        }
      }
    } catch {
      print("Error fetching feed: \(error)")
    }
    
    await MainActor.run {
      self.refreshTime = Date().formatted()
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
  
  func fetchOgTag(for url: URL, completion: @escaping (String?, String?, URL?) -> Void) async {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let html = String(data: data, encoding: .utf8)
      let document = try SwiftSoup.parse(html ?? "")
      
      let ogTitle = try document.select("meta[property=og:title]").attr("content")
      let ogDescription = try document.select("meta[property=og:description]").attr("content")
      let ogImageString = try document.select("meta[property=og:image]").attr("content")
      let ogImage = URL(string: ogImageString)
      
      completion(ogTitle, ogDescription, ogImage)
    } catch {
      completion(nil, nil, nil)
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

