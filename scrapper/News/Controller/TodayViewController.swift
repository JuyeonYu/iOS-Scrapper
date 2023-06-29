//
//  TodayViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/28.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import SwiftSoup
import FeedKit

class TodayViewController: UIViewController {
  let googleTrendsURL = URL(string: "https://trends.google.com/trends/trendingsearches/daily/rss?geo=KR")!
  let feedURL = URL(string: "https://trends.google.co.kr/trends/trendingsearches/daily/rss?geo=KR")!
  let zumURL = URL(string: "https://zum.com")!
  var issueKeywords: [[RSSFeedItem]] = []
  @IBOutlet weak var tableView: UITableView!
  let refreshControl = UIRefreshControl()
  override func viewDidLoad() {
    super.viewDidLoad()
        
    tableView.dataSource = self
    tableView.delegate = self
    tableView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(fetchRSS), for: .valueChanged)
  }
  
  private func groupRSSByDay(rss: [RSSFeedItem]) -> [[RSSFeedItem]] {
    var result: [[RSSFeedItem]] = []
    var currentGroup: [RSSFeedItem] = []
    for i in 0 ..< rss.count {
      let currentRSS = rss[i]
      if i == 0 {
        currentGroup.append(currentRSS)
      } else {
        let prev = rss[i - 1]
        
        if (prev.pubDate?.day ?? 0 == currentRSS.pubDate?.day) {
          currentGroup.append(currentRSS)
        } else {
          result.append(currentGroup)
          currentGroup = [currentRSS]
        }
      }
    }
    
    if !currentGroup.isEmpty {
      result.append(currentGroup)
    }
    return result
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchRSS()
  }
  
  @objc func fetchRSS() {
    Task {
      let rss = try await fetchRSS()
      let sorted = rss.sorted { $0.pubDate ?? Date() > $1.pubDate ?? Date() }
      issueKeywords = groupRSSByDay(rss: sorted)
      tableView.refreshControl?.endRefreshing()
      tableView.reloadData()
    }
  }
  
  private func fetchRSS() async throws -> [RSSFeedItem] {
    let parser = FeedParser(URL: feedURL)
    
    let result = try await parser.parse()
    
    switch result {
    case .success(let success):
      return success.rssFeed?.items ?? []
    case .failure(let failure):
      throw failure
    }
  }
}


extension TodayViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let pubDate = issueKeywords[section].first?.pubDate else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월 dd일"
    return formatter.string(from: pubDate)
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let keyword = issueKeywords[indexPath.section][indexPath.row].title else { return }
    let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") { coder in
      return NewsListViewController(coder: coder, keyword: keyword)
    }
    guard let vc else { return }
    vc.navigationItem.title = keyword
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension TodayViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    issueKeywords.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    issueKeywords[section].count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let issue = issueKeywords[indexPath.section][indexPath.row]
    let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    cell.accessoryType = .disclosureIndicator
    
    var content = cell.defaultContentConfiguration()
    content.text = issue.title
    content.image = UIImage(systemName: "\(indexPath.row + 1).circle.fill")?
      .withRenderingMode(.alwaysOriginal)
      .withTintColor(indexPath.row == 0 ? UIColor(named: "Theme")! : .systemGray)
    cell.contentConfiguration = content
    return cell
  }
}
