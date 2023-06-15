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
    self.navigationItem.title = "카테고리"
    let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonDidClick))
    self.navigationItem.rightBarButtonItem = rightButtonItem
    
    // MARK: - Tableview setting
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
    
    let nibName = UINib(nibName: "CategoryTableViewCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "CategoryTableViewCell")
    
    // MARK: - get data for tableview
    for i in 0...10 {
      let category: Category = Category(category: "category\(i)")
      categoryList.append(category)
    }
  }
  
  @objc func rightBarButtonDidClick() {
    let title = "카테고리"
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    alert.addTextField { (tf) in
      tf.placeholder = "카테고리를 입력하세요"
    }
    
    let cancel = UIAlertAction(title: "취소", style: .cancel)
    let ok = UIAlertAction(title: "추가", style: .default) { (_) in
      
      //            TODO: - guard let 구문 사용 불가? 어떻게 사용해야 할지 모르겠음
      let text = alert.textFields?[0].text
      guard (text != "") else {
        return
      }
      let category = Category(category: text!)
      self.categoryList.append(category)
      self.tableView.reloadData()  
    }
    alert.addAction(cancel)
    alert.addAction(ok)
    self.present(alert, animated: true)
  }
}

extension CategortyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let vc: UIViewController = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") as! NewsListViewController
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
