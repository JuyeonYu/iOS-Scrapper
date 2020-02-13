//
//  NewsListViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var newsList: [News] = []
    var searchKeyword: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self

        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")
        
        guard let keyword = searchKeyword else {
            return
        }
        NetworkManager.sharedInstance.requestNaverNewsList(keyword: keyword) { (result) in
            debugPrint(1)
        }
//
//            // MARK: - get data for tableview
        for i in 0...10 {
            let news: News = News(title: "news\(i)")
            newsList.append(news)
        }
    }
}

    extension NewsListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let vc: UIViewController = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
            self.navigationController?.pushViewController(vc, animated: true)
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
