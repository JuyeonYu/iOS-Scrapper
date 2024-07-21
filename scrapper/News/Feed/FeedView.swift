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
  @State private var selectedURL: URL? = nil
  
  init() {
    let realm = try! Realm()
    _viewModel = StateObject(wrappedValue: FeedViewModel(realm: realm))
  }
  
  let functions: FirebaseFunctions.Functions = Functions.functions()
  var body: some View {
    GeometryReader(content: { geometry in
      
      
      NavigationView {
        if viewModel.isLoading || !viewModel.isLogin || viewModel.newsList.isEmpty {
          VStack {
            if viewModel.isLoading {
              LottieViewEntry(.loading)
                .padding()
                .frame(height: 100)
            } else if !viewModel.isLogin {
              
              Text("로그인이 필요한 서비스입니다.").font(.headline)
              
              LottieViewEntry(.login)
                .padding()
                .frame(height: 300)
              
              Button(action: {
                UserDefaultManager.setIsUser(false)
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController()
              }, label: {
                Text("Login")
                  .font(.headline)
                  .foregroundColor(.white)
                  .padding()
                  .background(
                    LinearGradient(gradient: Gradient(colors: [Color.purple, .init("Theme")]), startPoint: .leading, endPoint: .trailing)
                  )
                  .cornerRadius(15)
                  .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 10)
                
              })
              
            } else {
              Text("등록한 키워드에 뉴스가 없습니다.")
              LottieViewEntry(.noFeed)
                .padding()
                .frame(height: 300)
            }
          }.navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              Button(action: {
                Task {
                  await viewModel.fetchFeed()
                }
              }) {
                HStack {
                  Text(viewModel.refreshTime)
                    .foregroundColor(.primary)
                  Image(systemName: "arrow.clockwise.circle.fill").tint(Color("Theme"))
                }
              }
            }
        } else {
          List {
            ForEach(viewModel.newsList) { news in
              NavigationLink(
                destination: SafariView(url: selectedURL ?? URL(string: "https://example.com")!),
                isActive: Binding<Bool>(
                  get: { selectedURL != nil },
                  set: { isActive in
                    if isActive {
                      // Reset selectedURL only when the link is no longer active
                      DispatchQueue.main.async {
                        selectedURL = nil
                      }
                    }
                  }
                )
              ) {
                HStack {
                  if let url = news.ogImage {
                    KFImage(url)
                      .placeholder {
                        ProgressView()
                      }
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 100, height: 80)
                      .clipped()
                  } else {
                    EmptyView()
                      .frame(height: 0)
                  }
                  VStack {
                    Text(news.title)
                      .font(.headline)
                      .foregroundColor(.primary)
                    Text(news.itemDescription)
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                  }.frame(height: 80)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                  if let url = URL(string: news.link) {
                    selectedURL = url
                  }
                }
              }
            }
          }
          .listStyle(.sidebar)
          .navigationTitle("Feed")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            Button(action: {
              Task {
                await viewModel.fetchFeed()
              }
            }) {
              HStack {
                Text(viewModel.refreshTime)
                  .foregroundColor(.primary)
                Image(systemName: "arrow.clockwise.circle.fill").tint(Color("Theme"))
              }
            }
          }
        }
      }
    })
  }
}

#Preview {
  FeedView()
}
