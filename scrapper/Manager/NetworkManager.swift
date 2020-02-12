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
        let url = "http://15.164.97.144:5000/mainKeyword"
        let param = ["userid":"jill"]
        
        AF.request(url, parameters: param, encoder: URLEncodedFormParameterEncoder(destination: .methodDependent)).responseJSON { response in
//            debugPrint("Response: \(response)")
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
}
