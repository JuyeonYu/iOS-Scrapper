//
//  NetworkManager.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/12.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
  static let sharedInstance = NetworkManager()
  
  init() {}
    

    func requestNaverNewsListAsync(keyword: String, sort: String, start: Int) async throws -> NaverNews {
        let urlString = "https://openapi.naver.com/v1/search/news.json"
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "display", value: "100"),
            URLQueryItem(name: "start", value: "\(start)"),
            URLQueryItem(name: "sort", value: sort)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            Bundle.main.object(forInfoDictionaryKey: "NaverSearchAPIId") as? String,
            forHTTPHeaderField: "X-Naver-Client-Id"
        )
        request.setValue(
            Bundle.main.object(forInfoDictionaryKey: "NaverSearchAPISecret") as? String,
            forHTTPHeaderField: "X-Naver-Client-Secret"
        )
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(NaverNews.self, from: data)
            
            return result
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }

  
  func requestNaverNewsList(keyword: String, sort: String, start: Int, completion: @escaping (Any) -> Void) {
    let url = "https://openapi.naver.com/v1/search/news.json"
    let param = ["query":keyword, "display":100, "start":start, "sort":sort] as [String : Any]
    let headers: HTTPHeaders = [
      "Content-Type": "application/json",
      "X-Naver-Client-Id": Bundle.main.object(forInfoDictionaryKey: "NaverSearchAPIId") as! String,
      "X-Naver-Client-Secret": Bundle.main.object(forInfoDictionaryKey: "NaverSearchAPISecret") as! String
    ]
    
    AF.request(url, parameters: param, headers: headers).responseJSON { response in
      switch response.result {
      case .success(let obj):
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
          let decoder = JSONDecoder()
          let getData = try decoder.decode(NaverNews.self, from: jsonData)
          completion(getData)
        } catch {
          print(error.localizedDescription)
        }
      case .failure(let e):
        print(e.localizedDescription)
      }
    }
  }
}
