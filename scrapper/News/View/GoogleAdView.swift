//
//  GoogleAdView.swift
//  scrapper
//
//  Created by  유 주연 on 7/25/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct GoogleAdView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
      let viewController = UIViewController()
      let bannerSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
      let banner = GADBannerView(adSize: bannerSize)
      banner.rootViewController = viewController
      viewController.view.addSubview(banner)
      viewController.view.frame = CGRect(origin: .zero, size: bannerSize.size)
      banner.adUnitID = Constants.googleADModBannerID
      banner.load(GADRequest())
      return viewController
  }

  func updateUIViewController(_ viewController: UIViewController, context: Context) {

  }
}
