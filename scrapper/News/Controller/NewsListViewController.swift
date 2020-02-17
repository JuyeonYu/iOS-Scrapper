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
    var seachSort = "date"
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButtonItem = UIBarButtonItem.init(title: "최신순", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
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

        requestNaverNewsList(keyword: keyword, sort: seachSort)
    }
    
    func requestNaverNewsList(keyword: String, sort: String) {
        NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword, sort: sort) { (result) in
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
            self.seachSort = "date"
            
//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.seachSort)
            self.tableView.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "관련도순", style: .default, handler: { result in
            self.navigationItem.rightBarButtonItem?.title = "관련도순"
            self.seachSort = "date"
            
//            키워드 페이지에서 검색할 키워드를 줌
            guard let keyword = self.searchKeyword else {
                return
            }
            self.newsList.removeAll()
            self.requestNaverNewsList(keyword: keyword, sort: self.seachSort)
            self.tableView.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
        

    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safariVC = SFSafariViewController(url: URL(string: newsList[indexPath.row].urlString)!)
        present(safariVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bookMarkAction = UIContextualAction(style: .normal, title:  "즐겨찾기", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let news = self.newsList[indexPath.row]
            let newsRealm = NewsRealm()
            newsRealm.title = news.title
            newsRealm.urlString = news.urlString
            newsRealm.publishTime = news.publishTime
            
            try! self.realm.write {
                self.realm.add(newsRealm)
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
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        let row = indexPath.row
        
        cell.titleLabel.text = newsList[row].title
        cell.publishTimeLabel.text = Util.sharedInstance.naverTimeFormatToNormal(date: newsList[row].publishTime)
        
        return cell
    }
    
    
}
