//
//  Constant.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/12.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation

struct Constants {
    
    struct UserDefault {
        static let newsOrder = "UserDefaultNewsOrder"
    }
    
    static let baseURL = "http://15.164.97.144:5000/"
    static let mainKeyword = "mainKeyword"
    static let userid = "userid"
    
    static let naverNewsAPIBaseURL = "https://openapi.naver.com/v1/search/news.json?query="
    static let naverNewsAPDisplayParameter = "&display="
    static let naverNewsAPIStartPageParameter = "&start="
    static let naverNewsAPIStartSortParameter = "&sort="
    
    struct UserDefault {
        static let login = "UserDefaultLogin"
        static let userID = "UserDefaultUserID"
    }
}


