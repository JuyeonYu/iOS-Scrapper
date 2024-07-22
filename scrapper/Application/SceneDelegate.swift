//
//  SceneDelegate.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  let remoteConfig = RemoteConfig.remoteConfig()
  let settings = RemoteConfigSettings()

  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    settings.minimumFetchInterval = 0
    remoteConfig.configSettings = settings

    guard let _ = (scene as? UIWindowScene) else { return }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    guard let windowScene = scene as? UIWindowScene else { return }
    guard let window = windowScene.windows.first else { return }
    guard let tabBarController = window.rootViewController as? UITabBarController else {
        return
    }
    guard let navigationController = tabBarController.children[tabBarController.selectedIndex] as? UINavigationController,
          let keywordViewController = navigationController.children.first as? KeywordViewController else { return }
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    UserDefaultManager.setFetchNew(timestamp: Date().timeIntervalSince1970)
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    NotificationCenter.default.post(name: NSNotification.Name("checkNews"), object: nil)
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    
    
    remoteConfig.fetch() { (status, error) -> Void in
        if status == .success {
          self.remoteConfig.activate() { (changed, error) in
                print(changed, error)
            let remoteVersion = self.remoteConfig["version"].stringValue?.split(separator: ".").compactMap { version in Int(version) } ?? []
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

  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
}

