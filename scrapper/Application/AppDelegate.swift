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
import FirebaseRemoteConfig

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

    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0
    remoteConfig.configSettings = settings
    
    remoteConfig.fetch() { (status, error) -> Void in
        if status == .success {
            remoteConfig.activate() { (changed, error) in
                print(changed, error)
              let remoteVersion = remoteConfig["version"].stringValue?.split(separator: ".").compactMap { version in Int(version) } ?? []
              let currentVersion = Bundle.version.split(separator: ".").compactMap { Int($0)}
                            
              guard remoteVersion.count == 3 && currentVersion.count == 3 else { return }
              
              guard remoteVersion[0] != currentVersion[0] || remoteVersion[1] != currentVersion[1] || remoteVersion[2] != currentVersion[2] else {
                return
              }
              
              guard remoteVersion[0] > currentVersion[0] || remoteVersion[1] > currentVersion[1] || remoteVersion[2] > currentVersion[2] else {
                return
              }
              
              let alert = UIAlertController(title: "알림", message: "새로운 기능이 업데이트 되었습니다. 업데이트가 필요합니다.", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "업데이트", style: .default, handler: { _ in
                guard let url = URL(string: Constants.appDownloadURL) else {
                    return
                }
                DispatchQueue.main.async {
                  if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                  }
                }
              }))
              DispatchQueue.main.async {
                UIApplication.shared.windows.first?.rootViewController?.present(alert: alert)
              }
                
            }
        } else {
            print("Error: \(error?.localizedDescription ?? "No error available.")")
        }
    }


    
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
    } else if let data = userInfo["keywords"] as? String,
              let link = URL(string: data) {
      UIApplication.shared.windows.first?.rootViewController?.presentSafari(url: link)
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


extension UIViewController {
    func presentSafari(url: URL, delegate: SFSafariViewControllerDelegate? = nil) {
        DispatchQueue.main.async {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: url, configuration: config)
            safariVC.delegate = delegate

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootViewController = scene.windows.first?.rootViewController {
                    rootViewController.present(safariVC, animated: true, completion: nil)
                }
            } else {
                // For iOS versions before 13.0, fallback to the previous method
                UIApplication.shared.windows.first?.rootViewController?.present(safariVC, animated: true, completion: nil)
            }
        }
    }
}
