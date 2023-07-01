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
  var noneGroupId: UUID?
  @IBOutlet weak var tableView: UITableView!
  func getGroupRealm(section: Int) -> GroupRealm? {
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    guard section < groupList.count else { return nil }
    return groupList[section]
  }
  func getKeywordList(section: Int) -> [KeywordRealm] {
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keywordList = Array(realm.objects(KeywordRealm.self)).sorted { $0.timestamp < $1.timestamp }
    return keywordList.filter { $0.gourpId == groupList[section].id}
  }
  func getKeywordRealm(indexPath: IndexPath) -> KeywordRealm? {
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keywordList = Array(realm.objects(KeywordRealm.self)).sorted { $0.timestamp < $1.timestamp }
    
    let groupId = groupList[indexPath.section].id
    return keywordList.filter { $0.gourpId == groupId }[indexPath.row]
  }
  
  @IBAction func onPlus(_ sender: Any) {
    
    tableView.isEditing = false
    let alert = UIAlertController(title: "", message: "무엇을 추가할까요?", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "그룹", style: .default) { _ in
      let maxGroup = UserDefaultManager.getMaxGroupCount()
      let currentGroupCount = Array(self.realm.objects(GroupRealm.self)).count
      if currentGroupCount >= maxGroup {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayViewController"), animated: true)
      } else {
        self.popupAddGroup()
      }
    })
    alert.addAction(UIAlertAction(title: "키워드", style: .default) { _ in
      let maxKeyword = UserDefaultManager.getMaxKeywordCount()
      let currentKeywordCount = Array(self.realm.objects(KeywordRealm.self)).count
      if currentKeywordCount >= maxKeyword {
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PayViewController"), animated: true)
      } else {
        self.popupAddKeyword()
      }
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    present(alert: alert)
    
  }
  @IBAction func onMinus(_ sender: Any) {
  }
  @IBAction func onEdit(_ sender: Any) {
    tableView.isEditing = !tableView.isEditing
    if tableView.isEditing {
      edit.title = "완료"
    } else {
      edit.title = "편집"
    }
    tableView.reloadData()
  }
  @IBOutlet weak var edit: UIBarButtonItem!
  @IBOutlet weak var bannerView: GADBannerView!
  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  let keywordCellID = "KeywordTableViewCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Tableview setting
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
    
    tableView.register(UINib(nibName: "KeywordTableViewCell", bundle: nil), forCellReuseIdentifier: "KeywordTableViewCell")
    tableView.register(UINib(nibName: "KeywordGroupHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "KeywordGroupHeader")
    // get data for tableview
    
    if realm.objects(KeywordRealm.self).count == 0 {
      popupAddKeyword()
    }
    
    bannerView.adUnitID = Constants.googleADModBannerID
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
    
    if let noneGroup = realm.objects(GroupRealm.self).filter({ $0.name == ""}).first {
      noneGroupId = noneGroup.id
    } else {
      let id = UUID()
      try! self.realm.write {
        let groupRealm = GroupRealm()
        groupRealm.name = ""
        groupRealm.id = id
        groupRealm.timestamp = Date().timeIntervalSince1970
        self.realm.add(groupRealm)
      }
      noneGroupId = id
    }
    
    // DB 마이그레이션 용도. 기존에 만든 키워드 중 groupId나 timestamp가 없는 키워드를 기본 그룹에 넣음
    try! self.realm.write {
      let keywordsRealm = Array(realm.objects(KeywordRealm.self))
      let noneGroupId = realm.objects(GroupRealm.self).filter{ $0.name.isEmpty }.first?.id
      keywordsRealm.filter { $0.timestamp == 0.0 }.forEach { $0.timestamp = Date().timeIntervalSince1970 }
      keywordsRealm.filter { $0.gourpId == nil }.forEach { $0.gourpId = noneGroupId }
    }
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tableView.isEditing = false
  }
  func popupAddGroup() {
    let alert = UIAlertController(title: NSLocalizedString("Group", comment: ""),
                                  message: NSLocalizedString("Please enter group what you want", comment: ""),
                                  preferredStyle: .alert)
    
    alert.addTextField { (tf) in
      tf.placeholder = NSLocalizedString("Please enter group what you want", comment: "")
    }
    
    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
    let ok = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (_) in
      let saveKeyword = alert.textFields?[0].text
      
      guard let keyword = saveKeyword else {
        return
      }
      
      // [1.1-NS003] @juyeon / 중복 키워드 방지
      guard (self.realm.objects(GroupRealm.self).filter("name = '\(keyword)'").isEmpty) else {
        let alert = UIAlertController(title: NSLocalizedString("Group", comment: ""),
                                      message: NSLocalizedString("Let's search another one!", comment: ""),
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default)
        alert.addAction(ok)
        self.present(alert: alert)
        return
      }
      
      let groupRealm = GroupRealm()
      groupRealm.name = saveKeyword!
      groupRealm.id = UUID()
      groupRealm.timestamp = Date().timeIntervalSince1970
      try! self.realm.write {
        self.realm.add(groupRealm)
      }
      self.tableView.reloadData()
    }
    alert.addAction(cancel)
    alert.addAction(ok)
    self.present(alert: alert)
  }
  func popupAddKeyword() {
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
        self.present(alert: alert)
        return
      }
      
      let keywordRealm = KeywordRealm()
      keywordRealm.keyword = saveKeyword!
      keywordRealm.exceptionKeyword = exceptionKeyword!
      keywordRealm.timestamp = Date().timeIntervalSince1970
      keywordRealm.gourpId = self.noneGroupId
      try! self.realm.write {
        self.realm.add(keywordRealm)
      }
      self.tableView.reloadData()
    }
    alert.addAction(cancel)
    alert.addAction(ok)
    self.present(alert: alert)
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
    self.present(alert: alert)
  }
}


extension KeywordViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    50
  }
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KeywordGroupHeader") as! KeywordGroupHeader
    header.section = section
    header.delegate = self
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keywordList = Array(realm.objects(KeywordRealm.self))
    
    let group = groupList[section]
    let keywordCount = keywordList.filter { $0.gourpId == group.id }.count
    
    header.configure(group: group, keywordCount: keywordCount, isEditing: tableView.isEditing)
    return header
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let keywordRealm = getKeywordRealm(indexPath: indexPath) else { return }
    
    let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") { coder in
      return NewsListViewController(coder: coder, keyword: keywordRealm.keyword)
    }
    guard let vc else { return }
    vc.navigationItem.title = keywordRealm.keyword
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 오른쪽으로 밀어서 메뉴 보는 함수
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard let keywordRealm = getKeywordRealm(indexPath: indexPath) else { return nil }
    let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      
      
      // realm에서 먼저 삭제 한다.
      try! self.realm.write {
        self.realm.delete(keywordRealm)
      }
      tableView.reloadData()
      success(true)
    })
    
    let editAction = UIContextualAction(style: .normal, title: NSLocalizedString("Edit", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      self.editExceptionKeyword(keyword: keywordRealm.keyword, exceptionKeyword: keywordRealm.exceptionKeyword)
    })
    return UISwipeActionsConfiguration(actions:[deleteAction, editAction])
  }
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  
}

extension KeywordViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    guard let sourceKeyword = getKeywordRealm(indexPath: sourceIndexPath) else { return }
    let destinationKeywordList = getKeywordList(section: destinationIndexPath.section)
    let newTimestamp: TimeInterval
    
    if destinationIndexPath.row == 0 {
      newTimestamp = (destinationKeywordList.first?.timestamp ?? 1) - 1
    } else if destinationIndexPath.row + 1 == destinationKeywordList.count || destinationIndexPath.row == destinationKeywordList.count {
      newTimestamp = (destinationKeywordList.last?.timestamp ?? 1) + 1
    } else {
      newTimestamp = (destinationKeywordList[destinationIndexPath.row].timestamp + destinationKeywordList[destinationIndexPath.row - 1].timestamp) / 2
    }
    
    try! self.realm.write {
      sourceKeyword.timestamp = newTimestamp
      if sourceIndexPath.section != destinationIndexPath.section {
        sourceKeyword.gourpId = groupList[destinationIndexPath.section].id
      }
    }
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    realm.objects(GroupRealm.self).count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keywordList = Array(realm.objects(KeywordRealm.self)).sorted { $0.timestamp < $1.timestamp }
    
    if keywordList.isEmpty {
      self.tableView.setEmptyMessage(NSLocalizedString("Why don't you add some new keyword?", comment: ""))
    } else {
      self.tableView.restore()
    }
    let groupId = groupList[section].id
    if keywordList.contains(where: { $0.gourpId == nil}) {
      return keywordList.filter { $0.gourpId == nil }.count
    } else {
      return keywordList.filter { $0.gourpId == groupId }.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let keywordRealm = getKeywordRealm(indexPath: indexPath) else { return UITableViewCell() }
    let cell = self.tableView.dequeueReusableCell(withIdentifier: keywordCellID, for: indexPath) as! KeywordTableViewCell
    cell.config(keyword: keywordRealm)
    return cell
  }
}

extension KeywordViewController: KeywordGroupHeaderDelegate {
  func onUp(section: Int) {
    guard section > 0 else { return }
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    try! realm.write {
      let source = groupList[section]
      let temp = source.timestamp
      source.timestamp = groupList[section - 1].timestamp
      groupList[section - 1].timestamp = temp
    }
    let sourceHeader = (tableView.headerView(forSection: section) as? KeywordGroupHeader)
    let destinationHeader = (tableView.headerView(forSection: section - 1) as? KeywordGroupHeader)
    sourceHeader!.section! -= 1
    
    if let destinationHeader {
      destinationHeader.section! += 1
      tableView.moveSection(section, toSection: section - 1)
    } else {
      UIView.transition(with: tableView,
                        duration: 0.35,
                        options: .transitionCrossDissolve,
                        animations: { self.tableView.reloadData() })
    }
  }
  func onDown(section: Int) {
    guard section < realm.objects(GroupRealm.self).count - 1 else { return }
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    try! realm.write {
      let source = groupList[section]
      let temp = source.timestamp
      source.timestamp = groupList[section + 1].timestamp
      groupList[section + 1].timestamp = temp
    }
    
    let sourceHeader = (tableView.headerView(forSection: section) as? KeywordGroupHeader)
    let destinationHeader = (tableView.headerView(forSection: section + 1) as? KeywordGroupHeader)
    sourceHeader!.section! += 1
    
    if let destinationHeader {
      destinationHeader.section! -= 1
      tableView.moveSection(section, toSection: section + 1)
    } else {
      UIView.transition(with: tableView,
                        duration: 0.35,
                        options: .transitionCrossDissolve,
                        animations: { self.tableView.reloadData() })
    }
  }
  func onDelete(section: Int) {
    guard let groupRealm = getGroupRealm(section: section) else { return }
    let keywordList = getKeywordList(section: section)
    if keywordList.isEmpty {
      try! realm.write({
        realm.delete(groupRealm)
      })
      tableView.deleteSections([section], with: .left)
    } else {
      let alert  = UIAlertController(title: "삭제", message: "등록된 키워드들도 함께 삭제됩니다.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "취소", style: .cancel))
      alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
        try! self.realm.write({
          self.realm.delete(groupRealm)
          keywordList.forEach {
            self.realm.delete($0)
          }
        })
        self.tableView.deleteSections([section], with: .left)
      })
      self.present(alert: alert)
    }
    
  }
}

