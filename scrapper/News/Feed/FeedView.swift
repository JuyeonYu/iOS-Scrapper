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
import Kingfisher

struct FeedView: View {
  @StateObject private var viewModel: FeedViewModel
  @State private var selectedNews: Item? = nil

  init() {
    let realm = try! Realm()
    _viewModel = StateObject(wrappedValue: FeedViewModel(realm: realm))
  }
  
  let functions: FirebaseFunctions.Functions = Functions.functions()
  var body: some View {
    NavigationView(content: {
      List {
        ForEach(viewModel.newsList) { news in
          
          VStack(alignment: .leading) {
            Text(news.title)
              .font(.headline)
              .foregroundColor(.primary)
            if let url = news.ogImage {
              
//                KFImage(url)
//                  .placeholder({
//                    ProgressView()
//                      .frame(height: 200)
//                  })
//                  .resizable()
//                  .frame(height: 200, alignment: .center)
              }
            }
          Text(news.itemDescription)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .onTapGesture {
              if let url = URL(string: news.link) {
                self.selectedNews = news
              }
            }
        }
        
      }
      
      .navigationTitle("feed")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: {
        Button(action: {
          Task {
            await viewModel.fetchFeed()
          }
        }, label: {
          HStack {
            Text(viewModel.refreshTime)
              .foregroundColor(.primary)
            Image(systemName: "arrow.clockwise.circle.fill")
          }
        })
      })
      .sheet(item: $selectedNews) { news in
        SafariView(url: URL(string: news.link)!)
      }
    })
  }
}

#Preview {
  FeedView()
}
