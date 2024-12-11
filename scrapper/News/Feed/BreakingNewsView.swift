//
//  BreakingNewsView.swift
//  scrapper
//
//  Created by  유 주연 on 12/11/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import SwiftUI

struct BreakingNewsView: View {
    @State private var naviateTitle: String = "속보"
    @State private var news: [[Item]] = []
    @State private var page: Int = 1
    @State private var lowestVisibleSection: Int = 0
    @State private var fetching: Bool = false
    var body: some View {
        NavigationView {
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
                        naviateTitle = news[lowestVisibleSection].first?.timeAgo ?? ""
                    }
                    .onAppear {
                        if section < lowestVisibleSection {
                            lowestVisibleSection = section
                        }
                        naviateTitle = news[lowestVisibleSection].first?.timeAgo ?? ""
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
            .refreshable {
                page = 1
                Task {
                    self.news = await fetchNews()
                }
            }
        }.task {
            page = 1
            news = await fetchNews()
        }
    }
    
    private func fetchNews() async -> [[Item]] {
        do {
            return try await NetworkManager.sharedInstance.requestNaverNewsListAsync(
                keyword: "속보",
                sort: "date",
                start: page
            )
            .groupedItems
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

#Preview {
    BreakingNewsView()
}
