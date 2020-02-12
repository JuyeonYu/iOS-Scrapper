//
//  KeywordViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class KeywordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var keywordList: [Keyword] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Navigation setting
        self.navigationItem.title = "키워드"
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonDidClick))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "KeywordTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "KeywordTableViewCell")
        
        // MARK: - get data for tableview
        NetworkManager.sharedInstance.requestKeywordList { (response) in
            guard let keywordListFromDB = response else {
                return
            }
            
            for keyword in keywordListFromDB {
                let keyword: Keyword = Keyword(keyword: keyword)
                self.keywordList.append(keyword)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func rightBarButtonDidClick() {
        let title = "키워드"
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                
                alert.addTextField { (tf) in
                    tf.placeholder = "키워드를 입력하세요"
                }
                
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                let ok = UIAlertAction(title: "추가", style: .default) { (_) in
                    let text = alert.textFields?[0].text
                    guard (text != "") else {
                        return
                    }
                    let keyword = Keyword(keyword: text!)
                    self.keywordList.append(keyword)
                    self.tableView.reloadData()
                }
                alert.addAction(cancel)
                alert.addAction(ok)
                self.present(alert, animated: true)
    }
}


extension KeywordViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: UIViewController = self.storyboard?.instantiateViewController(identifier: "CategortyViewController") as! CategortyViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension KeywordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "KeywordTableViewCell", for: indexPath) as! KeywordTableViewCell
        let row = indexPath.row
        cell.titleLabel.text = keywordList[row].keyword
        return cell
    }
}
