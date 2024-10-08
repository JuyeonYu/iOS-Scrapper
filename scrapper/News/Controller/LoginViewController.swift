//
//  LoginViewController.swift
//  scrapper
//
//  Created by  유 주연 on 7/3/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import FirebaseDatabase
import FirebaseAppCheck

class LoginViewController: UIViewController {
  // Unhashed nonce.
  @IBOutlet weak var logo: UIImageView!
  fileprivate var currentNonce: String?
  
  var firebaseDB: DatabaseReference!

  @IBAction func goWithoutAuth(_ sender: Any) {
    let alert  = UIAlertController(title: "알림", message: "비회원은 새로운 뉴스의 알림을 받아보실 수 없습니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "게스트로 이용하기", style: .default, handler: { _ in
      UserDefaultManager.setIsUser(true)
      (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController()
    }))
    alert.addAction(UIAlertAction(title: "로그인하기", style: .destructive, handler: { _ in
      self.onLogin(())
    }))
    present(alert: alert)
  }
  
  @IBAction func onLogin(_ sender: Any) {
    startSignInWithAppleFlow()

  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    logo.layer.cornerRadius = 16
    self.firebaseDB = Database.database(url: "https://news-scrap-b64dd-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    // TODO: app check
//    AppCheck.appCheck().token(forcingRefresh: true) { token, error in
//      print(token)
//    }
  }
}

extension LoginViewController {
  func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)
      
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
  }
  
  func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
          fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
          )
      }
      let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      let nonce = randomBytes.map { byte in
          // Pick a random character from the set, wrapping around if needed.
          charset[Int(byte) % charset.count]
      }
      return String(nonce)
  }
  
  func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
          String(format: "%02x", $0)
      }.joined()
      
      return hashString
  }

}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error Apple sign in: \(error.localizedDescription)")
                    return
                }
              if let uid = authResult?.user.uid {
                if let fcmToken = KeychainHelper.shared.loadString(key: KeychainKey.fcmToken.rawValue) {
                  self.firebaseDB.child(uid).child("fcm_token").setValue(fcmToken)
                }
              }
                // 로그인에 성공했을 시 실행할 메서드 추가
              UserDefaultManager.setIsUser(true)
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
      // Apple 로그인 인증 창 띄우기
        return self.view.window ?? UIWindow()
    }
}
