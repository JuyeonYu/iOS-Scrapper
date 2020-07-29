//
//  Constant.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/12.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation

struct Constants {
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
        static let pushToken = "UserDefaultPushToke n"
    }
    
    struct RestAPI {
        static let baseURL = "http://182.213.68.34:3000"
        static let kUser = "user"
        static let kID = "id"
        static let kPushToken = "pushToken"
        static let kKeyword = "keyword"
        static let kLatestNewsTime = "latestNewsTime"
        static let kAalarmOn = "alarmOn"
        static let kAlarmTime = "alarmTime"
        static let kUnreadCount = "unreadCount"
    }
}


