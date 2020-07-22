//
//  ViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self .setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaultsManager.getLogin() {
            goMainController()
        }
    }
    
    func setupProviderLoginView() {
      let authorizationButton = ASAuthorizationAppleIDButton()
      authorizationButton.addTarget(self,
                                    action: #selector(handleAuthorizationAppleIDButtonPress),
                                    for: .touchUpInside)
      self.loginStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
            
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    func saveLogin() {
        UserDefaultsManager.setLogin(login: true)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    fileprivate func goMainController() {
        let mainViewController = self.storyboard?.instantiateViewController(identifier: "mainViewController")
        mainViewController?.modalPresentationStyle = .fullScreen
        self.present(mainViewController!, animated: true, completion: saveLogin)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            goMainController()
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            goMainController()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

