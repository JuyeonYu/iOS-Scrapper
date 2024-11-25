//
//  SelectGroupViewController.swift
//  scrapper
//
//  Created by  유 주연 on 11/23/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import UIKit
import RealmSwift

class SelectGroupViewController: UIViewController {
  var keyword: String = ""
  var exceptionKeyword: String?

  @IBAction func onAdd(_ sender: Any) {
    guard let selectedGroup else { return }
    let keywordRealm = KeywordRealm()
    keywordRealm.keyword = keyword
    keywordRealm.exceptionKeyword = exceptionKeyword ?? ""
    keywordRealm.timestamp = Date().timeIntervalSince1970
    keywordRealm.gourpId = selectedGroup.id
    keywordRealm.hasNews = true
    FirestoreManager().upsert(keyword: KeywordFirestore(keywordRealm: keywordRealm))
    try! self.realm.write {
      self.realm.add(keywordRealm)
    }

    navigationController?.popToRootViewController(animated: false)
  }
  var selectedGroup: GroupRealm?
  var groups: [GroupRealm] = []
  lazy var realm: Realm = {
    return try! Realm()
  }()
  @IBOutlet weak var add: UIButton!
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    add.isEnabled = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(.init(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
    groups = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
  }
}

extension SelectGroupViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
    cell.configure(group: groups[indexPath.row])
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedGroup = groups[indexPath.row]
    add.backgroundColor = UIColor(named: "Theme")
    add.isEnabled = true
  }
}
