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
