//
//  BreakingNewsView.swift
//  scrapper
//
//  Created by  유 주연 on 12/11/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

enum TrendingType: CaseIterable, Identifiable {
    var id: TrendingType {
        self
    }
    
    case breakingNews
    case exclusive
    
    var title: String {
        switch self {
        case .breakingNews:
            return "속보"
        case .exclusive:
            return "단독"
        }
    }
}

struct BreakingNewsView: View {
    @State private var selectedType: TrendingType = .breakingNews
    @State private var onNoti: Bool = false
    @State private var naviateTitle: String = "속보"
    @State private var news: [[Item]] = []
    @State private var page: Int = 1
    @State private var lowestVisibleSection: Int = 0
    @State private var fetching: Bool = false
    var body: some View {
        
        NavigationView {
            ScrollViewReader { proxy in
            VStack {
                    List {
                        ForEach(0..<news.count, id: \.self) { section in
                            Section(news[section].first?.timeAgo ?? "") {
                                ForEach(0..<news[section].count, id: \.self) { row in
                                    VStack(alignment: .leading) {
                                        Text(.init(news[section][row].title))
                                            .font(.headline)
                                        if !news[section][row].itemDescription.isEmpty {
                                            Text(.init(news[section][row].itemDescription))
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .onDisappear {
                                if section == lowestVisibleSection {
                                    lowestVisibleSection += 1
                                }
                                guard section + 1 < news.count else { return }
                                naviateTitle = "\(selectedType.title)(\(news[lowestVisibleSection].first?.timeAgo ?? ""))"
                            }
                            .onAppear {
                                if section < lowestVisibleSection {
                                    lowestVisibleSection = section
                                }
                                
                                naviateTitle = "\(selectedType.title)(\(news[lowestVisibleSection].first?.timeAgo ?? ""))"
                                guard section == news.count - 1 else { return }
                                guard !fetching else { return }
                                Task {
                                    page += 100
                                    fetching = true
                                    let fetchedNews = await fetchNews()
                                    news.append(contentsOf: fetchedNews)
                                    fetching = false
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle(naviateTitle)
                    .onChange(of: selectedType, perform: { _ in
                        Task {
                            page = 1
                            news = await fetchNews()
                            proxy.scrollTo(0, anchor: .top)
                        }
                    })
                }
                
//                Picker("", selection: $selectedType) {
//                    ForEach(TrendingType.allCases, id: \.self) { type in
//                        Text(type.title).tag(type)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal, 16)
            }
            
//            .navigationBarItems(
//                trailing: HStack {
//                    Image(systemName: onNoti ? "bell.fill" : "bell").tint(Color("Theme"))
//                        .padding(8)
//                        .onTapGesture {
//
//                            FirestoreManager().toggleBreakingNewsNoti(on: !onNoti)
//                            onNoti.toggle()
//                            if let uid = Auth.auth().currentUser?.uid {
//                                Database.database(url: "https://news-scrap-b64dd-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child(uid).child("keywords").setValue(["속보"])
//                            }
//                        }
//                  })
            .refreshable {
                page = 1
                Task {
                    self.news = await fetchNews()
                }
            }
        }.task {
            onNoti = await FirestoreManager().getUserReceiveBreakingNews()
            page = 1
            news = await fetchNews()
            
        }
    }
    
    private func fetchNews() async -> [[Item]] {
        do {
            let res = try await NetworkManager.sharedInstance.requestNaverNewsListAsync(
                keyword: selectedType.title,
                sort: "date",
                start: page
            )
            
            return res.groupedItems
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

#Preview {
    BreakingNewsView()
}
