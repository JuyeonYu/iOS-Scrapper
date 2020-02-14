//
//  BookMarkViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/14.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift

class BookMarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var newsListRealm: [NewsRealm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.tabBarController?.delegate = self
        
        let nibName = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "NewsTableViewCell")
        
        // MARK: - get data for tableview
        for news in realm.objects(NewsRealm.self) {
            newsListRealm.append(news)
        }
    }
}

extension BookMarkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
        vc.newsURLString = newsListRealm[indexPath.row].urlString
        self.navigationController?.pushViewController(vc, animated: true)
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
        return newsListRealm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        let row = indexPath.row
        cell.titleLabel.text = newsListRealm[row].title
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
