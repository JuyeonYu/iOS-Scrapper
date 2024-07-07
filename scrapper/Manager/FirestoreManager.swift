//
//  FirestoreManager.swift
//  scrapper
//
//  Created by  유 주연 on 7/6/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import AdSupport
import RealmSwift

enum FirestoreCollectionType: String {
  case user
  case keyword
}

enum PaidType: Int {
  case year
  case month
  case none
}

struct FirestoreManager {
  let firestore = Firestore.firestore()
  func upsert(collection: FirestoreCollectionType, documentId: String = UUID().uuidString, dict: [String: Any]) {
    let documentRef = firestore.collection(collection.rawValue).document(documentId)
    documentRef.getDocument { snapshot, error in
      if let snapshot, snapshot.exists {
        documentRef.updateData(dict)
      } else {
        documentRef.setData(dict)
      }
    }
  }
  func setData(collection: FirestoreCollectionType, documentId: String = UUID().uuidString, dict: [String: Any]) {
    firestore.collection(collection.rawValue).document(documentId).setData(dict)
  }
  
  
  func delete(collection: FirestoreCollectionType, documentId: String) {
    firestore.collection(collection.rawValue).document(documentId).delete()
  }
  
  func upsert(keyword: KeywordFirestore) {
    guard let userId = keyword.userId else { return }
    guard let dict = keyword.dict else { return }
    upsert(collection: .keyword, documentId: userId + keyword.keyword, dict: dict)
  }
  func updateKeywordNoti(keyword: String, enable: Bool) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    upsert(collection: .keyword, documentId: userId + keyword, dict: ["noti_enable": enable])
  }
  func delete(keyword: KeywordFirestore) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let collectionRef = firestore.collection(FirestoreCollectionType.keyword.rawValue)
    
    collectionRef.getDocuments { snapshot, error in
      guard let documents = snapshot?.documents else { return }
      documents
        .filter { $0.data()["keyword"] as? String == keyword.keyword && $0.data()["user_id"] as? String == userId }
        .map { $0.documentID }
        .forEach { documentID in
          collectionRef.document(documentID).delete()
        }
    }
  }
  
  func upsert(keywords: [KeywordFirestore]) {
    keywords.forEach { upsert(keyword: $0) }
  }
  
  func saveUser() {
    guard let id: String = Auth.auth().currentUser?.uid else { return }
    guard let fcmToken: String = KeychainHelper.shared.loadString(key: KeychainKey.fcmToken.rawValue) else { return }
    
    upsert(collection: .user, documentId: id, dict: [
      "fcm_token": fcmToken
    ])
  }
  
  func sync() {
    guard let userId = Auth.auth().currentUser?.uid else { return }

    // TODO: 로그인 기록이 없으면 가지고 있는 키워드 전부를 업로드함. 이후에 하나씩 추가할 때만 업로드. 로그인 버전이 안착되면 이 코드 필요없음
    firestore.collection(FirestoreCollectionType.user.rawValue).document(userId).getDocument(completion: { snapshot, error in
      guard let snapshot, !snapshot.exists else { return }
      
      let realm = try! Realm()
      Array(
        realm.objects(KeywordRealm.self).map {
          KeywordFirestore(keywordRealm: $0)
        }
      ).forEach {
        setData(collection: .keyword, documentId: userId + $0.keyword, dict: $0.dict ?? [:])
      }
    })
    
    saveUser()
  }
}
