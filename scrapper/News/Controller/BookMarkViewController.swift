//
//  BookMarkViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/14.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class BookMarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var newsListRealm: [NewsRealm] = []
    var newsTitleListRealm: [String] = []
    var filteredNews: [NewsRealm] = []
    var dataList: [NewsRealm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        searchBar.delegate = self
        searchBar.placeholder = "뉴스를 검색해보세요."
        
        self.navigationController?.tabBarController?.delegate = self
        
        // MARK: - Navigation setting
        self.navigationItem.title = "북마크"
        
        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")
        
        // MARK: - get data for tableview
        for news in realm.objects(NewsRealm.self) {
            newsListRealm.append(news)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // realm에 저장되어 있는 이미 읽은 뉴스 기사 제목을 리스트로 저장.
        // 기사를 보고 뒤로 돌아오는 경우 읽은 기사 표시를 하기 위해 이 시점에 저장.
        for news in realm.objects(ReadNewsRealm.self) {
            newsTitleListRealm.append(news.title)
        }
        
        tableView.reloadData()
    }

}

extension BookMarkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.newsListRealm[indexPath.row]
        
        // 뉴스를 누르면 읽은 뉴스로 저장
        let readNews = ReadNewsRealm()
        readNews.title = news.title
        readNews.urlString = news.urlString

        if !newsTitleListRealm.contains(readNews.title) {
            try! self.realm.write({
                self.realm.add(readNews)
            })
        }
        
        let safariVC = SFSafariViewController(url: URL(string: newsListRealm[indexPath.row].urlString)!)
        present(safariVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // realm에서 먼저 삭제 한다.
            try! self.realm.write {
                self.realm.delete(self.newsListRealm[indexPath.row])
            }
            
            // 리스트에서 삭제한다.
            self.newsListRealm.remove(at: indexPath.row)
            tableView.reloadData()
            success(true)
        })
                
        let shareAction = UIContextualAction(style: .normal, title:  "공유", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let row = indexPath.row
            let newsTitle = self.newsListRealm[row].title
            let newsURL = self.newsListRealm[row].urlString
            let newsArray = [newsTitle, newsURL]
            
            let activityViewController = UIActivityViewController(activityItems: newsArray, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
                        
            success(true)
        })
        return UISwipeActionsConfiguration(actions:[deleteAction, shareAction])
    }
}

extension BookMarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" && searchBar.text != nil && searchBar.isFirstResponder {
            return filteredNews.count
        } else {
            return newsListRealm.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        let row = indexPath.row
        
        if searchBar.text != "" && searchBar.isFirstResponder {
            dataList = filteredNews
        } else {
            dataList = newsListRealm
        }
        cell.titleLabel.text = dataList[row].title
        cell.publishTimeLabel.text = Util.sharedInstance.naverTimeFormatToNormal(date: dataList[row].publishTime)
        
        // 이미 읽은 기사를 체크하기 위해
        if self.newsTitleListRealm.contains(dataList[row].title) {
            print("이미 읽은 뉴스 기사 제목 \(dataList[row].title)")
            cell.titleLabel.textColor = UIColor.lightGray
            cell.publishTimeLabel.textColor = UIColor.lightGray
        }
        return cell
    }
}

extension BookMarkViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            for news in realm.objects(NewsRealm.self) {
                newsListRealm.append(news)
            }
        } else {
            newsListRealm.removeAll()
        }
        self.tableView.reloadData()
    }
}

extension BookMarkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNews.removeAll()
        
        for news in newsListRealm {
            if news.title.contains(searchText) {
                print("검색된 뉴스:  \(news.title)")
                filteredNews.append(news)
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
