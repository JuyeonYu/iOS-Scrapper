//
//  UserDefaultsManager.swift
//  scrapper
//
//  Created by 주연  유 on 2020/07/18.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static func setLogin(login: Bool) {
        UserDefaults.standard.set(login, forKey: Constants.UserDefault.login)
    }
    
    static func getLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.UserDefault.login)
    }
}
