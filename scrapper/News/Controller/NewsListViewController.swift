//
//  NewsListViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import GoogleMobileAds


class NewsListViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  let refreshControl = UIRefreshControl()
  var newsList: [News] = []
  var searchedNews: [News] = []
  var dataList: [News] = []
  var newsViewCount: Int = 0
  let popupAdNewsViewCount: Int = 10
  let lastReadNewsOriginalLink: String?
  var keywordRealm: KeywordRealm?
  let keyword: String
  init?(coder: NSCoder, keyword: String) {
    self.keyword = keyword
    self.lastReadNewsOriginalLink = UserDefaultManager.getLastReadNewsOriginalLink(keyword: keyword)
    super.init(coder: coder)
    self.keywordRealm = self.realm.objects(KeywordRealm.self).filter("keyword = '\(keyword)'").first
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  let naverDateFormatter = DateFormatter()
  let dateFormatter = DateFormatter()
  var searchSort = "sim" // 기본값은 관련도 검색
  var searchSortBarTitle = "Related order" // 기본값은 관련도 검색
  @IBOutlet weak var searchBar: UISearchBar!
  
  private var interstitial: GADInterstitialAd?
  @IBOutlet weak var bannerView: GADBannerView!
  
  var safariVC: SFSafariViewController?
  var matchLastRead: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()    
    

    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    if UserDefaultManager.getNewsOrder() == "date" {
      searchSortBarTitle = "Latest order"
      searchSort = "date"
    } else {
      searchSortBarTitle = "Related order"
      searchSort = "sim"
    }
    let rightButtonItem = UIBarButtonItem.init(title: NSLocalizedString(searchSortBarTitle, comment: ""),
                                               style: .plain,
                                               target: self,
                                               action: #selector(rightBarButtonDidClick))
    self.navigationItem.rightBarButtonItem = rightButtonItem
    
    // MARK: - Tableview setting
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
    
    searchBar.delegate = self
    searchBar.placeholder = NSLocalizedString("Please search news", comment: "")
    tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
    
    // 시간 포멧 변경 세팅
    naverDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z" // 네이버 api에서 넘어오는 시간 포멧
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm" // 내가 뿌리고 싶은 시간 포멧
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 네이버 포멧에서 gmt + 9 값으로 주기 때문에 로컬로 변경 필요
    
    
    requestNaverNewsList(keyword: keyword, start: 1)
    
    Task {
      if await IAPManager.isPro() {
        bannerView.isHidden = true
      } else {
        bannerView.isHidden = false
        bannerView.adUnitID = Constants.googleADModBannerID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadAd()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let link = newsList.first?.originalLink {
      UserDefaultManager.setLastReadNewsOriginalLink(keyword: keyword, link: link)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
      
      try! realm.write({
        keywordRealm?.hasNews = false
          keywordRealm?.lastReadTimestamp = Date().timeIntervalSince1970
      })
  }
  
  func requestNaverNewsList(keyword: String, start: Int) {
    if start == 1 {
      newsList.removeAll()
    }
    NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword, sort: searchSort, start: start) { (result) in
      guard let naverNews = result as? NaverNews else {
        return
      }
      
      let exceptKeywords = Array(self.realm.objects(KeywordRealm.self))
        .filter { $0.keyword == keyword }
        .map { $0.exceptionKeyword }
      let exceptDomains = Array(self.realm.objects(exceptNews.self))
        .map { $0.domain }
      
      let filteredNews =
      naverNews.items
        .map { News(title: $0.title, urlString: $0.link, originalLink: $0.originallink, publishTime: $0.pubDate) }
        .filter { news in !exceptKeywords.contains(where: { news.title.contains($0) })}
        .filter { news in !exceptDomains.contains(where: { news.originalLink.contains($0) })}
      
      if UserDefaultManager.getExclusivePress() {
        
      }
      self.newsList.append(contentsOf: filteredNews)
      self.tableView.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    }
  }
  
  func removeExceptionKeywordNews(exceptionKeyword: String, newsList: [News]) -> [News] {
    var resultNews: [News] = newsList
    
    for news in resultNews {
      var index = 0
      if news.title.contains(exceptionKeyword) {
        resultNews.remove(at: index)
        index = index + 1
      }
    }
    return resultNews
  }
  @objc func refresh() {
    requestNaverNewsList(keyword: keyword, start: 1)
  }
  
  @objc func rightBarButtonDidClick() {
    let actionSheet = UIAlertController(title: NSLocalizedString("You can choose the order", comment: ""), message: nil, preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Latest order", comment: ""), style: .default, handler: { result in
      self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Latest order", comment: "")
      self.searchSort = "date"
      
      UserDefaultManager.setNewsOrder(order: "date")
      
      self.newsList.removeAll()
      self.requestNaverNewsList(keyword: self.keyword, start: 1)
      self.tableView.reloadData()
    }))
    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Related order", comment: ""), style: .default, handler: { result in
      self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Related order", comment: "")
      self.searchSort = "sim"
      
      UserDefaultManager.setNewsOrder(order: "sim")
      
      self.newsList.removeAll()
      self.requestNaverNewsList(keyword: self.keyword, start: 1)
      self.tableView.reloadData()
    }))
    actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
    
    if UIDevice.current.userInterfaceIdiom == .pad { //디바이스 타입이 iPad일때
      if let popoverController = actionSheet.popoverPresentationController { // ActionSheet가 표현되는 위치를 저장해줍니다.
        popoverController.sourceView = self.view
        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
        self.present(actionSheet, animated: true, completion: nil)
      }
    } else {
      self.present(actionSheet, animated: true, completion: nil)
    }
  }
  fileprivate func loadAd() {
    let request = GADRequest()
    
    GADInterstitialAd.load(withAdUnitID: Constants.googleADModFullPageID,
                           request: request,
                           completionHandler: { [self] ad, error in
      if let error = error {
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        return
      }
      interstitial = ad
      interstitial?.fullScreenContentDelegate = self
    })
  }
}

extension NewsListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let news = self.newsList[indexPath.row]
    
    // 뉴스를 누르면 읽은 뉴스로 저장
    let readNewsRealm = ReadNewsRealm()
    readNewsRealm.title = news.title
    
    if realm.objects(ReadNewsRealm.self).filter("title = '\(news.title)'").isEmpty {
      try! realm.write({
        realm.add(readNewsRealm)
      })
    }
    
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    safariVC = SFSafariViewController(url: URL(string: newsList[indexPath.row].urlString)!, configuration: config)
    safariVC?.delegate = self
    
    if (interstitial != nil && newsViewCount == popupAdNewsViewCount) && !bannerView.isHidden {
      newsViewCount = 0
      interstitial!.present(fromRootViewController: self)
    } else {
      present(safariVC!, animated: true, completion: nil)
      newsViewCount += 1
    }
    
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    /*
     1. 북마크 하기 전 realm에 저장된 북마크를 조회한다.
     2. 북마크하려는 제목과 realm에 저장된 북마크 제목을 비교한다.
     3. 북마크된 적 없는 기사에 북마크 버튼을 누르면 realm에 해당 기사를 저장한다.
     4. 북마크된 적이 없는 기사면 북마트 버튼 색을 파란색으로 한다.
     */
    let news = self.newsList[indexPath.row]
    // 1, 2
    let isBookmarked = !realm.objects(BookMarkNewsRealm.self).filter("title = '\(news.title)'").isEmpty
    
    let bookMarkAction = UIContextualAction(style: .normal, title: NSLocalizedString("Bookmark", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      // 3
      if !isBookmarked {
        let bookMarkNewsRealm = BookMarkNewsRealm()
        bookMarkNewsRealm.title = news.title
        bookMarkNewsRealm.urlString = news.urlString
        bookMarkNewsRealm.publishTime = news.publishTime
        
        try! self.realm.write {
          self.realm.add(bookMarkNewsRealm)
          Util.sharedInstance.showToast(controller: self, message: NSLocalizedString("It is added in bookmark", comment: ""))
        }
      } else {
        Util.sharedInstance.showToast(controller: self, message: NSLocalizedString("You already added this news", comment: ""))
      }
      success(true)
    })
    
    let shareAction = UIContextualAction(style: .normal, title:  "공유", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      let row = indexPath.row
      let newsTitle = self.newsList[row].title
      let newsURL = self.newsList[row].urlString
      Util.sharedInstance.shareNews(self.newsList[row])
      success(true)
    })
    // 4
    if !isBookmarked {
      bookMarkAction.backgroundColor = UIColor(named: "Theme")
    }
    
    return UISwipeActionsConfiguration(actions:[bookMarkAction, shareAction])
  }
}

extension NewsListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchBar.text != "" && searchBar.text != nil && searchBar.isFirstResponder {
      return searchedNews.count
    } else {
      return newsList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
    let row = indexPath.row
    
    
    // 뉴스 페이징 처리
    if row == newsList.count-1 {
      requestNaverNewsList(keyword: keyword, start: row + 2)
    }
    
    // 검색한 데이터를 가져올지 아닐지 처리
    if searchBar.text != "" && searchBar.isFirstResponder {
      dataList = searchedNews
    } else {
      dataList = newsList
    }
    
    guard let news = dataList[safe: row] else { return UITableViewCell() }
    matchLastRead = (news.publishTimestamp ?? 0) > keywordRealm?.lastReadTimestamp ?? 0
    cell.configure(news: news, isNew: matchLastRead)
        
    // 이미 읽은 기사를 체크하기 위해
    if !self.realm.objects(ReadNewsRealm.self).filter("title = '\(news.title)'").isEmpty {
      cell.title.textColor = UIColor.lightGray
      cell.publishTime.textColor = UIColor.lightGray
    } else {
      cell.title.textColor = UIColor.label
      cell.publishTime.textColor = UIColor.label
    }
    return cell
  }
}

extension NewsListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchedNews.removeAll()
    
    for news in newsList {
      if news.title.contains(searchText) {
        print(news.title)
        searchedNews.append(news)
      }
    }
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar.endEditing(true)
  }
}

extension NewsListViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    self.tableView.reloadData()
  }
}

extension NewsListViewController: GADFullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    present(safariVC!, animated: true, completion: nil)
  }
}
