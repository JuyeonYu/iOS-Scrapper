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
import GoogleMobileAds

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
    var onNews: (
        (
            Item
        ) -> Void
    )
    @State private var selectedType: TrendingType = .breakingNews
    @State private var onNoti: Bool = false
    @State private var naviateTitle: String = "속보"
    @State private var news: [[Item]] = []
    @State private var page: Int = 1
    @State private var lowestVisibleSection: Int = 0
    @State private var fetching: Bool = false
    @State private var isPro: Bool = true
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    List {
                        ForEach(
                            0..<news.count,
                            id: \.self
                        ) { section in
                            Section(
                                news[section].first?.timeAgo ?? ""
                            ) {
                                ForEach(
                                    0..<news[section].count,
                                    id: \.self
                                ) { row in
                                    VStack(
                                        alignment: .leading
                                    ) {
                                        Text(
                                            .init(
                                                news[section][row].title
                                            )
                                        )
                                        .font(
                                            .headline
                                        )
                                        if !news[section][row].itemDescription.isEmpty {
                                            Text(
                                                .init(
                                                    news[section][row].itemDescription
                                                )
                                            )
                                            .font(
                                                .subheadline
                                            )
                                            .foregroundColor(
                                                .gray
                                            )
                                        }
                                    }
                                    .onTapGesture {
                                        onNews(
                                            news[section][row]
                                        )
                                    }
                                }
                            }
                            .onDisappear {
                                if section == lowestVisibleSection {
                                    lowestVisibleSection += 1
                                }
                                guard section + 1 < news.count else {
                                    return
                                }
                                naviateTitle = "\(selectedType.title)(\(news[lowestVisibleSection].first?.timeAgo ?? ""))"
                            }
                            .onAppear {
                                if section < lowestVisibleSection {
                                    lowestVisibleSection = section
                                }
                                
                                naviateTitle = "\(selectedType.title)(\(news[lowestVisibleSection].first?.timeAgo ?? ""))"
                                guard section == news.count - 1 else {
                                    return
                                }
                                guard !fetching else {
                                    return
                                }
                                Task {
                                    page += 100
                                    fetching = true
                                    let fetchedNews = await fetchNews()
                                    news
                                        .append(
                                            contentsOf: fetchedNews
                                        )
                                    fetching = false
                                }
                            }
                        }
                    }
                    .listStyle(
                        .insetGrouped
                    )
                    .navigationTitle(
                        naviateTitle
                    )
                    .refreshable {
                        page = 1
                        Task {
                            self.news = await fetchNews()
                        }
                    }
                    
                    if isPro {
                        EmptyView()
                    } else {
                        GoogleAdView()
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(
                                    UIScreen.main.bounds.width
                                ).size.height
                            )
                    }
                }
                if fetching {
                    LottieViewEntry(
                        .loading
                    )
                    .padding()
                    .frame(
                        height: 100
                    )
                }
            }.task {
                onNoti = await FirestoreManager()
                    .getUserReceiveBreakingNews()
                page = 1
                news = await fetchNews()
                isPro = await IAPManager
                    .isPro()
            }
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
            print(
                error.localizedDescription
            )
            return []
        }
    }
}

#Preview {
    BreakingNewsView(
        onNews: {
            _ in
        })
}
