//
//  AppDelegate.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//d

import UIKit
import RealmSwift
import GoogleMobileAds
import SwiftRater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var initialViewController :UIViewController?
  
  fileprivate func initRealm() {
    let version: UInt64 = 15
    let configCheck = Realm.Configuration();
    do {
      let fileUrlIs = try schemaVersionAtURL(configCheck.fileURL!)
      print("schema version \(fileUrlIs)") 
    } catch  {
      print(error)
    }
    
    let config = Realm.Configuration(
      schemaVersion: version,
      migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < version) {
        }
      })
    
    Realm.Configuration.defaultConfiguration = config
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    initRealm()
    SwiftRater.conditionsMetMode = .any
    SwiftRater.daysUntilPrompt = 7
    SwiftRater.usesUntilPrompt = 0
    SwiftRater.significantUsesUntilPrompt = 3
    SwiftRater.daysBeforeReminding = 1
    SwiftRater.showLaterButton = true
//    SwiftRater.debugMode = true
    SwiftRater.appLaunched()

    return true
  }
  
  
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

