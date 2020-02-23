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
    var searchKeyword: String?
    let realm = try! Realm()
    let naverDateFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    var searchSort = "sim" // 기본값은 관련도 검색
    var newsTitleListRealmForCheckRead: [String] = []
    var newsTitleListRealmForCheckBookMark: [String] = []
    var filteredNews: [News] = []
    var dataList: [News] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButtonItem = UIBarButtonItem.init(title: "관련도순", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        searchBar.delegate = self
        searchBar.placeholder = "뉴스를 검색해보세요."
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // realm에 저장되어 있는 이미 읽은 뉴스 기사 제목을 리스트로 저장.
        // 기사를 보고 뒤로 돌아오는 경우 읽은 기사 표시를 하기 위해 이 시점에 저장.
        for news in realm.objects(ReadNewsRealm.self) {
            newsTitleListRealmForCheckRead.append(news.title)
        }
        
        for news in realm.objects(NewsRealm.self) {
            newsTitleListRealmForCheckBookMark.append(news.title)
        }
        
        tableView.reloadData()
    }
    
    func requestNaverNewsList(keyword: String, sort: String, start: Int) {
        NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword, sort: sort, start: start) { (result) in
            guard let naverNews = result as? NaverNews else {
                return
            }
                    
            for news in naverNews.items {
                let news: News = News(title: news.title, urlString: news.link, publishTime: news.pubDate)
                self.newsList.append(news)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func rightBarButtonDidClick() {
        let actionSheet = UIAlertController(title: "어떤 순서로 뉴스를 보여드릴까요?", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "최신순", style: .default, handler: { result in
            self.navigationItem.rightBarButtonItem?.title = "최신순"
            self.searchSort = "date"
            
//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.searchSort, start: 1)
            self.tableView.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "관련도순", style: .default, handler: { result in
            self.navigationItem.rightBarButtonItem?.title = "관련도순"
            self.searchSort = "sim"
            
//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.searchSort, start: 1)
            self.tableView.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.newsList[indexPath.row]
        
        // 뉴스를 누르면 읽은 뉴스로 저장
        let readNews = ReadNewsRealm()
        readNews.title = news.title
        readNews.urlString = news.urlString

        if !newsTitleListRealmForCheckRead.contains(readNews.title) {
            try! self.realm.write({
                self.realm.add(readNews)
            })
        }
                
        let safariVC = SFSafariViewController(url: URL(string: newsList[indexPath.row].urlString)!)
        present(safariVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bookMarkAction = UIContextualAction(style: .normal, title:  "즐겨찾기", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let news = self.newsList[indexPath.row]
            
            // 중복된 기사면 저장 안해야함
            if !self.newsTitleListRealmForCheckBookMark.contains(news.title) {
                let newsRealm = NewsRealm()
                newsRealm.title = news.title
                newsRealm.urlString = news.urlString
                newsRealm.publishTime = news.publishTime
                
                try! self.realm.write {
                    self.realm.add(newsRealm)
                }
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
        
        bookMarkAction.backgroundColor = UIColor.blue
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
        
        if row == newsList.count-1 {
            requestNaverNewsList(keyword: self.searchKeyword!, sort: self.searchSort, start: row + 2)
        }
        
        if searchBar.text != "" && searchBar.isFirstResponder {
            dataList = filteredNews
        } else {
            dataList = newsList
        }
        cell.titleLabel.text = dataList[row].title
        cell.publishTimeLabel.text = Util.sharedInstance.naverTimeFormatToNormal(date: dataList[row].publishTime)
        
        // 이미 읽은 기사를 체크하기 위해
        if self.newsTitleListRealmForCheckRead.contains(dataList[row].title) {
            print("이미 읽은 뉴스 기사 제목 \(dataList[row].title)")
            cell.titleLabel.textColor = UIColor.lightGray
            cell.publishTimeLabel.textColor = UIColor.lightGray
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
