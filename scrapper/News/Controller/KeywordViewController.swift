//
//  KeywordViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift

class KeywordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var keywordList: [Keyword] = []
    var keywordListRealm: [KeywordRealm] = []
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Navigation setting
        self.navigationItem.title = "키워드"
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonDidClick))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        if keywordList.count == 0 {
            rightBarButtonDidClick()
        }

        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        let nibName = UINib(nibName: "KeywordTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "KeywordTableViewCell")
        
        // MARK: - get data for tableview
        for keyword in realm.objects(KeywordRealm.self) {
            keywordListRealm.append(keyword)
        }
        
        // TODO: 네트워크는 나중에 추가
//        NetworkManager.sharedInstance.requestKeywordList2(userid: "jill") { (response) in
//            guard let restAPIResponse = response else {
//                return
//            }
//
//            if restAPIResponse.isSuccess {
//                guard let keywordList = restAPIResponse.keywordList else {
//                    return
//                }
//                for keyword in keywordList {
//                    let keyword: Keyword = Keyword(keyword: keyword.keyword, idx_keyword: keyword.idx_keyword)
//                    self.keywordList.append(keyword)
//                    self.tableView.reloadData()
//                }
//            } else {
//                // TODO: fail case
//            }
//        }
    }
    
    @objc func rightBarButtonDidClick() {
        let title = "뉴스키워드"
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                
                alert.addTextField { (tf) in
                    tf.placeholder = "관심있는 뉴스키워드를 입력해보세요"
                }
                
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                let ok = UIAlertAction(title: "추가", style: .default) { (_) in
                    let text = alert.textFields?[0].text
                    guard (text != "") else {
                        return
                    }
//                    let keyword = Keyword(keyword: text!, index: nil)
//                    self.keywordList.append(keyword)
                    
                    let keywordRealm = KeywordRealm()
                    keywordRealm.keyword = text!
                    try! self.realm.write {
                        self.realm.add(keywordRealm)
                    }
                    self.keywordListRealm.append(keywordRealm)
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
        let keyword = self.keywordListRealm[row].keyword
        
        let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") as! NewsListViewController
        vc.navigationItem.title = keyword // 뉴스 페이지 제목 설정
        vc.searchKeyword = keyword
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    // 오른쪽으로 밀어서 메뉴 보는 함수
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // realm에서 먼저 삭제 한다.
            try! self.realm.write {
                self.realm.delete(self.keywordListRealm[indexPath.row])
            }
            
            // 리스트에서 삭제한다.
            self.keywordListRealm.remove(at: indexPath.row)
            tableView.reloadData()
            success(true)
        })
        return UISwipeActionsConfiguration(actions:[deleteAction])
    }
}

extension KeywordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if keywordListRealm.count == 0 {
            self.tableView.setEmptyMessage("관심있는 뉴스키워드가 없습니다.")
        } else {
            self.tableView.restore()
        }

        return keywordListRealm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "KeywordTableViewCell", for: indexPath) as! KeywordTableViewCell
        let row = indexPath.row
        cell.titleLabel.text = keywordListRealm[row].keyword
        return cell
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
