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
        
        // Navigation setting
        self.navigationItem.title = "키워드"
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(didTapAddKeywordButton))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        let nibName = UINib(nibName: "KeywordTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "KeywordTableViewCell")
        
        // get data for tableview
        if realm.objects(KeywordRealm.self).count == 0 {
            didTapAddKeywordButton()
        }
    }
    
    @objc func didTapAddKeywordButton() {
        let alert = UIAlertController(title: "뉴스키워드", message: "관심있는 키워드를 등록해보세요.", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "관심있는 뉴스키워드를 입력해보세요"
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "추가", style: .default) { (_) in
            let text = alert.textFields?[0].text

            guard let keyword = text else {
                return
            }
            
            // [1.1-NS003] @juyeon / 중복 키워드 방지
            guard (self.realm.objects(KeywordRealm.self).filter("keyword = '\(keyword)'").isEmpty) else {
                let alert = UIAlertController(title: "중복키워드", message: "다른 뉴스를 찾아볼까요?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                return
            }

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
        let keywordList = Array(realm.objects(KeywordRealm.self))
        let keyword = keywordList[row].keyword
        
        let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") as! NewsListViewController
        vc.navigationItem.title = keyword // 뉴스 페이지 제목 설정
        vc.searchKeyword = keyword
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    // 오른쪽으로 밀어서 메뉴 보는 함수
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            let keyword = self.realm.objects(KeywordRealm.self)[indexPath.row]

            // realm에서 먼저 삭제 한다.
            try! self.realm.write {
                self.realm.delete(keyword)
            }
            tableView.reloadData()
            success(true)
        })
        return UISwipeActionsConfiguration(actions:[deleteAction])
    }
}

extension KeywordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if realm.objects(KeywordRealm.self).count == 0 {
            self.tableView.setEmptyMessage("관심있는 뉴스키워드가 없습니다.")
        } else {
            self.tableView.restore()
        }
        return self.realm.objects(KeywordRealm.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "KeywordTableViewCell", for: indexPath) as! KeywordTableViewCell
        let row = indexPath.row
        let keywordList = Array(realm.objects(KeywordRealm.self))
        let keyword = keywordList[row].keyword
        cell.titleLabel.text = keyword
        return cell
    }
}
