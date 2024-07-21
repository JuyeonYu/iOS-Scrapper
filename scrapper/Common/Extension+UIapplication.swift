//
//  Extension+UIapplication.swift
//  scrapper
//
//  Created by  유 주연 on 7/21/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation

import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        return connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
}
