//
//  KeywordViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class KeywordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    let keywordCellID = "KeywordTableViewCell"
//    let googleADModID = "ca-app-pub-7604048409167711/3101460469"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation setting
        self.navigationItem.title = NSLocalizedString("Keyword", comment: "")
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add,
                                                   target: self,
                                                   action: #selector(didTapAddKeywordButton))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        tableView.register(KeywordTableViewCell.self, forCellReuseIdentifier: "KeywordTableViewCell")
        
        // get data for tableview
        
        if realm.objects(KeywordRealm.self).count == 0 {
            didTapAddKeywordButton()
        }
        
        bannerView.adUnitID = Constants.googleADModID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
        
    @objc func didTapAddKeywordButton() {
        let alert = UIAlertController(title: NSLocalizedString("Keyword", comment: ""),
                                      message: NSLocalizedString("Please enter keyword which make you interting", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = NSLocalizedString("Please enter keyword which make you interting", comment: "")
        }
        
        alert.addTextField { (tf) in
            tf.placeholder = NSLocalizedString("add exception keyword", comment: "")
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        let ok = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (_) in
            let saveKeyword = alert.textFields?[0].text
            let exceptionKeyword = alert.textFields?[1].text

            guard let keyword = saveKeyword else {
                return
            }
            
            // [1.1-NS003] @juyeon / 중복 키워드 방지
            guard (self.realm.objects(KeywordRealm.self).filter("keyword = '\(keyword)'").isEmpty) else {
                let alert = UIAlertController(title: NSLocalizedString("Keyword", comment: ""),
                                              message: NSLocalizedString("Let's search another news!", comment: ""),
                                              preferredStyle: .alert)
                let ok = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                return
            }

            let keywordRealm = KeywordRealm()
            keywordRealm.keyword = saveKeyword!
            keywordRealm.exceptionKeyword = exceptionKeyword!
            try! self.realm.write {
                self.realm.add(keywordRealm)
            }
            self.tableView.reloadData()
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func editExceptionKeyword(keyword: String, exceptionKeyword: String) {
        let alert = UIAlertController(title: NSLocalizedString("exception keyword", comment: ""),
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { (tf) in
            if exceptionKeyword == "" {
                tf.placeholder = NSLocalizedString("add exception keyword", comment: "")
            } else {
                tf.text = exceptionKeyword
            }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        let ok = UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { (_) in
            let exceptionKeyword = alert.textFields?[0].text
            
            let keywordRealm = self.realm.objects(KeywordRealm.self).filter("keyword = '\(keyword)'").first
            try! self.realm.write {
                keywordRealm?.exceptionKeyword = exceptionKeyword ?? ""
            }
            self.tableView.reloadData()
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
}


extension KeywordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let keywordList = Array(realm.objects(KeywordRealm.self))
        let keyword = keywordList[row].keyword
        
        
        let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") as! NewsListViewController
        vc.navigationItem.title = keyword // 뉴스 페이지 제목 설정
        vc.searchKeyword = keyword
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    // 오른쪽으로 밀어서 메뉴 보는 함수
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let keyword = self.realm.objects(KeywordRealm.self)[indexPath.row]

            // realm에서 먼저 삭제 한다.
            try! self.realm.write {
                self.realm.delete(keyword)
            }
            tableView.reloadData()
            success(true)
        })
        
        let editAction = UIContextualAction(style: .normal, title: NSLocalizedString("Edit", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let keyword = self.realm.objects(KeywordRealm.self)[indexPath.row].keyword
            let exceptionKeyword = self.realm.objects(KeywordRealm.self)[indexPath.row].exceptionKeyword
            self.editExceptionKeyword(keyword: keyword, exceptionKeyword: exceptionKeyword)
        })
        return UISwipeActionsConfiguration(actions:[deleteAction, editAction])
    }
}

extension KeywordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if realm.objects(KeywordRealm.self).count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("Why don't you add some new keyword?", comment: ""))
        } else {
            self.tableView.restore()
        }
        return realm.objects(KeywordRealm.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: keywordCellID, for: indexPath) as! KeywordTableViewCell
        let row = indexPath.row
        let keywordList = Array(realm.objects(KeywordRealm.self))
        let keyword = keywordList[row].keyword
        let exceptionKeyword = keywordList[row].exceptionKeyword
        cell.title.text = keyword
        cell.exceptionKeyword.text = "- " + exceptionKeyword
        cell.exceptionKeyword.isHidden = exceptionKeyword.isEmpty
        return cell
    }
}

extension KeywordViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    ///
    ////// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    ///
    ////// Tells the delegate that a full-screen view will be presented in response /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    ////// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    ////// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    ////// Tells the delegate that a user click will open another app (such as /// the App Store), backgrounding the current app.    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication") }
}
