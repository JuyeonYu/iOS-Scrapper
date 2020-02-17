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
    
    func requestKeywordList(completion: @escaping ([String]?) -> Void) {
        let url = Constants.baseURL + Constants.mainKeyword
        let param = [Constants.userid:"jill"]
        
        AF.request(url, parameters: param).responseJSON { response in
            switch response.result {
            case .success(let obj):
                guard let keywordList = obj as? Array<String> else {
                    return
                }
                completion(keywordList)

                for keyword in keywordList {
                    print(keyword)
                }
                break
            
            case .failure(let e):
                print(e.localizedDescription)
                break
            }
        }
    }
    
    func requestKeywordList2(userid:String, completion: @escaping (RestAPIResponse?) -> Void) {
        let url = Constants.baseURL + Constants.mainKeyword
        let param = [Constants.userid:userid]
        
        AF.request(url, parameters: param).responseJSON { response in

            switch response.result {
            case .success(let obj):
//                if let json = obj as? [Dictionary<String, NSObject>] {
//                    print(json)
//                }
                completion(nil)
                
                if let nsDictList = obj as? [NSDictionary] {
                    var keywordList: [Keyword] = []
                    for dict in nsDictList {
                        guard let keyword = dict["keyword"], let index = dict["idx_keyword"] else {
                            return
                        }
                        let keywordFromDB: Keyword = Keyword(keyword: keyword as? String, idx_keyword: index as? Int)
                        
                        keywordList.append(keywordFromDB)
                    }
                    let restAPIResponse: RestAPIResponse = RestAPIResponse(isSucces: true, message: "", keywordList: keywordList)
                    completion(restAPIResponse)
                }
                break
            
            case .failure(let e):
                print(e.localizedDescription)
                break
            }
        }
    }
    
    func requestNaverNewsList(keyword: String, sort: String, completion: @escaping (Any) -> Void) {
        let url = "https://openapi.naver.com/v1/search/news.json"
        let param = ["query":keyword, "display":"100", "start":"1", "sort":sort]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Naver-Client-Id": "zmO4KBQdHToxqh6FfuDv",
            "X-Naver-Client-Secret": "88YmMc4b62"
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
