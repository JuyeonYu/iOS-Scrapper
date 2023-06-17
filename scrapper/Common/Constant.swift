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
  
  static let googleADModID = "ca-app-pub-7604048409167711/3101460469"
  
  struct UserDefault {
    static let login = "UserDefaultLogin"
    static let userID = "UserDefaultUserID"
    static let newsOrder = "UserDefaultNewsOrder"
    static let exclusivePress = "UserDefaultexclusivePress"
  }
  
  static let press: [String] = ["KBS", "MBC", "SBS", "경향신문", "뉴스1", "뉴시스", "동아일보", "매일경제", "머니투데이", "서울신문", "아시아경제", "엑스포츠뉴스", "연합뉴스", "이데일리", "조선일보", "중앙일보", "티빙", "파이낸셜뉴스", "한겨레", "한국경제"]
  static let domain: [String: String] = [
    "조선일보": "chosun.com", "매일경제": "mk.co.kr", "연합뉴스": "yna.co.kr", "뉴시스": "newsis.com", "동아일보": "donga.com", "한국경제": "hankyung", "경향신문": "khan.co.kr", "머니투데이": "mt.co.kr", "중앙일보": "joongang.co.kr", "이데일리": "edaily.co.kr", "KBS": "kbs.co.kr", "뉴스1": "news1.kr", "SBS": "sbs.co.kr", "MBC": "imbc.com", "한겨레": "hani.co.kr", "파이낸셜뉴스": "fnnews.com", "아시아경제": "asiae.co.kr", "서울신문": "seoul.co.kr", "엑스포츠뉴스": "xportsnews.com", "티빙": "tving.com"
  ]
}


