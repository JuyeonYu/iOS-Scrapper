//
//  LottideView.swift
//  scrapper
//
//  Created by  유 주연 on 7/6/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import SwiftUI
import Lottie

public struct LottieViewEntry: View {
    public let lottie: LottieAnimationType
    public let loopMode: LottieLoopMode
    public let speed: CGFloat
    public enum LottieAnimationType: String {
        case coin, login, noData, loading, group
        internal var filename: String {
            switch self {
            case .coin: "9733-coin"
            case .login: "login"
            case .noData: "noData"
            case .loading: "loading"
            case .group: "group"
            }
        }
    }
    public init(_ lottie: LottieAnimationType, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.lottie = lottie
        self.loopMode = loopMode
        self.speed = speed
    }
    public var body: some View {
        LottieView(animation: .named(lottie.filename))
            .configure({ lottieView in
                lottieView.animationSpeed = speed
                lottieView.loopMode = loopMode
            })
            .playing()
    }
}

#Preview {
    LottieViewEntry(.coin, loopMode: .loop, speed: 1.0)
}
