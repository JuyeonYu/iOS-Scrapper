//
//  NewsViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var newsList: [News] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Navigation setting
        self.navigationItem.title = "뉴스"
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self

        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")
//
//            // MARK: - get data for tableview
        for i in 0...10 {
            let news: News = News(title: "news\(i)")
            newsList.append(news)
        }
    }
}

    extension NewsViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let vc: UIViewController = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    extension NewsViewController: UITableViewDataSource {
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
