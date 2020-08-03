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
    
    func signUp(id: String, pushToken: String, completion: @escaping (RestAPIResponse) -> Void) {
        let url = Constants.RestAPI.baseURL + "/"
            + Constants.RestAPI.kUser + "/"
        
        let encodedURLString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let param = ["userID":id, "pushToken":pushToken]
        
        AF.request(encodedURLString, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(RestAPIResponse.init(isSuccess: true, message: nil, code: 200))
            case .failure(let e):
                completion(RestAPIResponse.init(isSuccess: false, message: nil, code: 200))
                print(e.localizedDescription)
            }
        }
    }
    
    func addKeyword(keywordRealm:KeywordRealm, completion: @escaping (RestAPIResponse) -> Void) {
        let url = Constants.RestAPI.baseURL + "/"
            + Constants.RestAPI.kKeyword + "/"
            + keywordRealm.keyword
        
        let encodedURLString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let param = [Constants.RestAPI.kUserID:keywordRealm.userID!]
        
        AF.request(encodedURLString, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(RestAPIResponse.init(isSuccess: true, message: nil, code: 200))
            case .failure(let e):
                completion(RestAPIResponse.init(isSuccess: false, message: nil, code: 200))
                print(e.localizedDescription)
            }
        }
    }
    
    func deleteKeyword(keywordRealm:KeywordRealm, completion: @escaping (RestAPIResponse) -> Void) {
        let url = Constants.RestAPI.baseURL + "/"
            + Constants.RestAPI.kKeyword + "/"
            + keywordRealm.keyword
        
        let encodedURLString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let param = [Constants.RestAPI.kUser:keywordRealm.userID!]
        
        AF.request(encodedURLString, method: .delete, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(RestAPIResponse.init(isSuccess: true, message: nil, code: 200))
            case .failure(let e):
                completion(RestAPIResponse.init(isSuccess: false, message: nil, code: 200))
                print(e.localizedDescription)
            }
        }
    }
    
    func updateKeyword(keywordRealm:KeywordRealm, completion: @escaping (RestAPIResponse) -> Void) {
        let url = Constants.RestAPI.baseURL + "/"
            + Constants.RestAPI.kKeyword + "/"
            + keywordRealm.keyword
        
        let encodedURLString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let param = [
            Constants.RestAPI.kUserID : keywordRealm.userID!,
            Constants.RestAPI.kLatestNewsTime : keywordRealm.latestNewsTime ?? "",
            Constants.RestAPI.kAlarmTime : keywordRealm.alarmTime ?? ""
            ] as [String : Any]
        
        AF.request(encodedURLString, method: .put, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(_):
                completion(RestAPIResponse.init(isSuccess: true, message: nil, code: 200))
            case .failure(let e):
                completion(RestAPIResponse.init(isSuccess: false, message: nil, code: 200))
                print(e.localizedDescription)
            }
        }
    }
}
