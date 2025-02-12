//
//  SplashViewController.swift
//  scrapper
//
//  Created by  유 주연 on 7/21/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

var forTest: Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}


class SplashViewController: UIViewController {
  @IBOutlet weak var logo: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      logo.layer.cornerRadius = 16
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    DispatchQueue.main.async {
      self.process.text = "확인중."
    }
    setRootViewController()
  }
  @IBOutlet weak var process: UILabel!
}
var gKeywordDict: [String: Bool] = [:]
extension SplashViewController {
  func setRootViewController() {
//      if forTest {
//          self.setRootViewController(name: "Main",
//                              identifier: "MainViewController")
//          return
//      }
      
      if let currentUser = Auth.auth().currentUser {
        DispatchQueue.main.async {
          self.process.text = "확인중.."
        }
          Task {
              gKeywordDict = await FirestoreManager().getKeywords()
              
              currentUser.getIDToken(completion: { token, error in
                  if let token {
                    DispatchQueue.main.async {
                      self.process.text = "확인중..."
                    }
                      KeychainHelper.shared.saveString(key: KeychainKey.firebaseAuthToken.rawValue, value: token)
                  }
                self.decideRootViewController()
                print("x->-1")
              })
          }
          
          
      } else {
          self.decideRootViewController()
        print("x->9")
      }
  }
    
    private func decideRootViewController() {
      DispatchQueue.main.async {
        self.process.text = "확인중...."
      }
        if UserDefaultManager.getIsUser() {
            self.setRootViewController(name: "Main",
                                identifier: "MainViewController")
          print("x->1")
        } else {
            self.setRootViewController(name: "Main",
                                identifier: "OnboardingViewController")
          print("x->2")
        }
    }
  
  private func setRootViewController(name: String, identifier: String) {
    DispatchQueue.main.async {
      DispatchQueue.main.async {
        self.process.text = "시작"
      }
      if let windowScene = UIApplication.shared.currentWindow?.windowScene {
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window = window
        print("x->3")
      } else {
        print("x->4")
        DispatchQueue.main.async {
          self.process.text = "대기"
        }
      }
    }
  }
}
