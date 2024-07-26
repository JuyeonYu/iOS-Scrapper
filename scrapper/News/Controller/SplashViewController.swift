//
//  SplashViewController.swift
//  scrapper
//
//  Created by  유 주연 on 7/21/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
  @IBOutlet weak var logo: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      logo.layer.cornerRadius = 16
//      setRootViewController()

        // Do any additional setup after loading the view.
    }
  
  override func viewDidAppear(_ animated: Bool) {
    setRootViewController()
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SplashViewController {
  func setRootViewController() {
      
      if let currentUser = Auth.auth().currentUser {
          currentUser.getIDToken(completion: { token, error in
              if let token {
                  KeychainHelper.shared.saveString(key: KeychainKey.firebaseAuthToken.rawValue, value: token)
              }
            self.decideRootViewController()
          })
      } else {
          self.decideRootViewController()
      }
  }
    
    private func decideRootViewController() {
        if UserDefaultManager.getIsUser() {
            self.setRootViewController(name: "Main",
                                identifier: "MainViewController")
        } else {
            self.setRootViewController(name: "Main",
                                identifier: "OnboardingViewController")
        }
    }
  
  private func setRootViewController(name: String, identifier: String) {
    DispatchQueue.main.async {
      if let windowScene = UIApplication.shared.currentWindow?.windowScene {
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window = window
      }
    }
  }
}
