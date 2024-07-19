//
//  FeedView.swift
//  scrapper
//
//  Created by  유 주연 on 7/19/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import SwiftUI
import FirebaseFunctions
import RealmSwift

struct FeedView: View {
    let functions: FirebaseFunctions.Functions = Functions.functions()
    var body: some View {
        NavigationView(content: {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("feed")
        }).task {
            functions.useEmulator(withHost: "127.0.0.1", port: 5001)
            guard let token = KeychainHelper.shared.loadString(key: KeychainKey.firebaseAuthToken.rawValue) else { return }
            
            let realm: Realm = try! Realm()
            let keywords: [String] = Array(realm.objects(KeywordRealm.self).map { $0.keyword })
            guard let keywordsJsonData = try? JSONEncoder().encode(keywords) else { return }
            guard let keywordsJson = String(data: keywordsJsonData, encoding: .utf8) else { return }
            
            functions.httpsCallable("feed").call(keywordsJson) { res, error in
                guard let value = res?.data as? String else { return }
                guard let data = value.data(using: .utf8) else { return }
                guard let fed = try? JSONDecoder().decode(([String]).self, from: data) else { return }
                print(fed)

            }
        }
        
    }
}

#Preview {
    FeedView()
}
