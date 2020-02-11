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

        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "KeywordTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "KeywordTableViewCell")
        
        // MARK: - get data for tableview
        for i in 0...10 {
            let keyword: Keyword = Keyword(keyword: "keyword\(i)", desc: "desc", publishDate: nil, link: nil, image: nil)
            keywordList.append(keyword)
        }
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
