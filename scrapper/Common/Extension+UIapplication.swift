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
        // Retrieve the active UIWindowScene
        if let windowScene = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            // Return the key window if available, otherwise return the first window
            return windowScene.windows
                .first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
        }
        // Fallback if no active UIWindowScene is found
        return connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}

