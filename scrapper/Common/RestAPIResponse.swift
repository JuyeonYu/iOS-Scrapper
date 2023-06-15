//
//  RestAPIResponse.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/12.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation

class RestAPIResponse {
  let isSuccess: Bool
  let message: String?
  let keywordList: [Keyword]?
  
  init(isSucces: Bool, message: String?, keywordList: [Keyword]?) {
    self.isSuccess = isSucces
    self.message = message
    self.keywordList = keywordList
  }
}
