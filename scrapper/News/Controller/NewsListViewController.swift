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


class NewsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var newsList: [News] = []
    var filteredNews: [News] = []
    var dataList: [News] = []
    var searchKeyword: String?
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    let naverDateFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    var searchSort = "sim" // 기본값은 관련도 검색
    var searchSortBarTitle = "Related order" // 기본값은 관련도 검색
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")
        
        // 시간 포멧 변경 세팅
        naverDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z" // 네이버 api에서 넘어오는 시간 포멧
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm" // 내가 뿌리고 싶은 시간 포멧
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 네이버 포멧에서 gmt + 9 값으로 주기 때문에 로컬로 변경 필요

//        키워드 페이지에서 검색할 키워드를 줌
        guard let keyword = searchKeyword else {
            return
        }

        requestNaverNewsList(keyword: keyword, sort: searchSort, start: 1)
    }
        
    func requestNaverNewsList(keyword: String, sort: String, start: Int) {
        NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword, sort: sort, start: start) { (result) in
            guard let naverNews = result as? NaverNews else {
                return
            }
            
            for news in naverNews.items {
                let news: News = News(title: news.title, urlString: news.link, publishTime: news.pubDate)
                if (!news.title.contains(self.getExceptionKeyword(keyword: keyword))) {
                    self.newsList.append(news)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func getExceptionKeyword(keyword: String) -> String {
        var result: String = ""
        let keywordList = Array(realm.objects(KeywordRealm.self))
        for keywordRealm in keywordList {
            if keywordRealm.keyword == keyword {
                result = keywordRealm.exceptionKeyword
                break
            }
        }
        return result
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
    
    @objc func rightBarButtonDidClick() {
        let actionSheet = UIAlertController(title: NSLocalizedString("You can choose the order", comment: ""), message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Latest order", comment: ""), style: .default, handler: { result in
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Latest order", comment: "")
            self.searchSort = "date"
            
            UserDefaultManager.setNewsOrder(order: "date")
            
//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.searchSort, start: 1)
            self.tableView.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Related order", comment: ""), style: .default, handler: { result in
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Related order", comment: "")
            self.searchSort = "sim"
            
            UserDefaultManager.setNewsOrder(order: "sim")

//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.searchSort, start: 1)
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
                
        let safariVC = SFSafariViewController(url: URL(string: newsList[indexPath.row].urlString)!)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
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
            Util.sharedInstance.showShareActivity(viewController: self, msg: newsTitle, image: nil, url: newsURL, sourceRect: nil)
            success(true)
        })
        // 4
        if !isBookmarked {
            bookMarkAction.backgroundColor = UIColor.blue
        }
        
        return UISwipeActionsConfiguration(actions:[bookMarkAction, shareAction])
    }
}

extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" && searchBar.text != nil && searchBar.isFirstResponder {
            return filteredNews.count
        } else {
            return newsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        let row = indexPath.row
        
        // 뉴스 페이징 처리
        if row == newsList.count-1 {
            requestNaverNewsList(keyword: self.searchKeyword!, sort: self.searchSort, start: row + 2)
        }
        
        // 검색한 데이터를 가져올지 아닐지 처리
        if searchBar.text != "" && searchBar.isFirstResponder {
            dataList = filteredNews
        } else {
            dataList = newsList
        }
        
        // realm에 데이터를 넣을 때 '가 들어가면 데이터를 넣고 뺄 때 오류가 생김. 그래서 realm에 '를 &squot;으로 저장함
        cell.titleLabel.text = dataList[row].title.stripOutHtml()?.replacingOccurrences(of: "&squot;", with: "\'")
        cell.publishTimeLabel.text = Util.sharedInstance.naverTimeFormatToNormal(date: dataList[row].publishTime)
        
        // 이미 읽은 기사를 체크하기 위해
            if !self.realm.objects(ReadNewsRealm.self).filter("title = '\(self.dataList[row].title)'").isEmpty {
                print("이미 읽은 뉴스 기사 제목 \(self.dataList[row].title)")
                cell.titleLabel.textColor = UIColor.lightGray
                cell.publishTimeLabel.textColor = UIColor.lightGray
            } else {
                cell.titleLabel.textColor = UIColor.label
                cell.publishTimeLabel.textColor = UIColor.label
            }
        return cell
    }
}

extension NewsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNews.removeAll()
        
        for news in newsList {
            if news.title.contains(searchText) {
                print(news.title)
                filteredNews.append(news)
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
