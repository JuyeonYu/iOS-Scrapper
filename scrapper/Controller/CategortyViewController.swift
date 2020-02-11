//
//  CategortyViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class CategortyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var categoryList: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Navigation setting
//        self.navigationController?.navigationBar.topItem?.title = "카테고리"
        self.navigationItem.title = "카테고리"
        
        // MARK: - Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CategoryTableViewCell")
        
        // MARK: - get data for tableview
        for i in 0...10 {
            let category: Category = Category(category: "category\(i)")
            categoryList.append(category)
        }
    }
}

extension CategortyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: UIViewController = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategortyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row = indexPath.row
        cell.titleLabel.text = categoryList[row].category
        return cell
    }
    
    
}
