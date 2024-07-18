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
import FirebaseCore
import FirebaseMessaging
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var initialViewController :UIViewController?
  
  fileprivate func initRealm() {
    let version: UInt64 = 19
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
    
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
      if granted {
        print("알림 등록이 완료되었습니다.")
      }
    }
    application.registerForRemoteNotifications()
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


extension AppDelegate: UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // foreground 상에서 알림이 보이게끔 해준다.
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound, .badge])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if userInfo[AnyHashable("page")] as? String == "pay" {
      let pay = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayViewController")
      DispatchQueue.main.async {
        UIApplication.shared.windows.first?.rootViewController?.present(pay, animated: true)
      }
    } else if let data = userInfo["keywords"] as? String{
        if let jsonData = data.data(using: .utf8) {
          do {
              guard let keywordDicts = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else { return }
              
              let hasNewsKeywords: [String] = keywordDicts.compactMap { $0["title"] as? String }
              
              if hasNewsKeywords.count == 1, let link = keywordDicts[0]["link"] as? String, let newUrl = URL(string: link) {
                  DispatchQueue.main.async {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true
                    let safariVC = SFSafariViewController(url: newUrl, configuration: config)
                    UIApplication.shared.windows.first?.rootViewController?.present(safariVC, animated: true, completion: nil)
                  }
              }
          } catch {
            print("Error decoding JSON: \(error)")
          }
        }
    }
    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken else { return }
    KeychainHelper.shared.saveString(key: KeychainKey.fcmToken.rawValue, value: fcmToken)
    FirestoreManager().sync()
  }
}
