//
//  NewsListViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift

class NewsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var newsList: [News] = []
    var searchKeyword: String?
    let realm = try! Realm()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")

//        키워드 페이지에서 검색할 키워드를 줌
        guard let keyword = searchKeyword else {
            return
        }

        NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword) { (result) in
            guard let naverNews = result as? NaverNews else {
                return
            }

            for news in naverNews.items {
                let news: News = News(title: news.title, urlString: news.link)
                self.newsList.append(news)
                self.tableView.reloadData()
            }
        }
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
        vc.newsURLString = newsList[indexPath.row].urlString
        vc.hidesBottomBarWhenPushed = true // 이동 시 하단 탭바 가림
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bookMarkAction = UIContextualAction(style: .normal, title:  "즐겨찾기", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let news = self.newsList[indexPath.row]
            let newsRealm = NewsRealm()
            newsRealm.title = news.title
            newsRealm.urlString = news.urlString
            
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
        return cell
    }
    
    
}
