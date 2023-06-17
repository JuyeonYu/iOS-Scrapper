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
  
  @IBAction func onPlus(_ sender: Any) {
    let alert = UIAlertController(title: "", message: "무엇을 추가할까요?", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "그룹", style: .default) { _ in
      self.popupAddGroup()
    })
    alert.addAction(UIAlertAction(title: "키워드", style: .default) { _ in
      self.popupAddKeyword()
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    present(alert, animated: true)
  }
  @IBAction func onMinus(_ sender: Any) {
  }
  @IBAction func onEdit(_ sender: Any) {
    tableView.isEditing = !tableView.isEditing
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
    
    bannerView.adUnitID = Constants.googleADModID
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
        self.present(alert, animated: true)
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
    self.present(alert, animated: true)
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
        self.present(alert, animated: true)
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
    let row = indexPath.row
    let keywordList = Array(realm.objects(KeywordRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keyword = keywordList[row].keyword
    
    
    let vc = self.storyboard?.instantiateViewController(identifier: "NewsListViewController") as! NewsListViewController
    vc.navigationItem.title = keyword // 뉴스 페이지 제목 설정
    vc.searchKeyword = keyword
    
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  // 오른쪽으로 밀어서 메뉴 보는 함수
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      let keyword = self.realm.objects(KeywordRealm.self).sorted { $0.timestamp < $1.timestamp }[indexPath.row]
      
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
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  
}

extension KeywordViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let keywordList = Array(realm.objects(KeywordRealm.self))
      .sorted { $0.timestamp < $1.timestamp }
    let newTimestamp: TimeInterval
    
    if destinationIndexPath.row == 0 {
      newTimestamp = keywordList.first!.timestamp - 1
    } else if destinationIndexPath.row == keywordList.count - 1 {
      newTimestamp = keywordList.last!.timestamp + 1
    } else {
      newTimestamp = (keywordList[destinationIndexPath.row].timestamp + keywordList[destinationIndexPath.row + 1].timestamp) / 2
    }
    
    try! self.realm.write {
      keywordList[sourceIndexPath.row].timestamp = newTimestamp
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
    let groupList = Array(realm.objects(GroupRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let keywordList = Array(realm.objects(KeywordRealm.self)).sorted { $0.timestamp < $1.timestamp }
    let groupId = groupList[indexPath.section].id
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: keywordCellID, for: indexPath) as! KeywordTableViewCell
    let row = indexPath.row
    var sectionKeywordList: [KeywordRealm]
    
    if keywordList.filter({ $0.gourpId == groupId }).isEmpty {
      sectionKeywordList = keywordList.filter { $0.gourpId == nil }
    } else {
      sectionKeywordList = keywordList.filter { $0.gourpId == groupId }
    }
    let keyword = sectionKeywordList[row].keyword
    let exceptionKeyword = sectionKeywordList[row].exceptionKeyword
    cell.titleLabel.text = keyword
    cell.exceptionLabel.text = "- " + exceptionKeyword
    cell.exceptionLabel.isHidden = exceptionKeyword.isEmpty
    setupGestureRecognizer(for: cell.contentView)

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
    destinationHeader!.section! += 1
    tableView.moveSection(section, toSection: section - 1)
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
    (tableView.headerView(forSection: section) as? KeywordGroupHeader)?.section = section + 1
    tableView.moveSection(section, toSection: section + 1)
  }
  
  func setupGestureRecognizer(for view: UIView) {
      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
      view.addGestureRecognizer(panGesture)
  }
  @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
      switch recognizer.state {
      case .began:
          // Start the reordering process
          guard let sectionView = recognizer.view else { return }
        let section = sectionView.tag
          tableView.beginUpdates()
          tableView.moveSection(section, toSection: tableView.numberOfSections - 1)
          tableView.endUpdates()
      case .changed: break
          // Update the visual position of the dragged section if needed
          // You can animate the change here to provide a smooth visual effect
      case .ended: break
          // End the reorde ring process
          // Update your data source to reflect the new section order
          tableView.reloadData()
      default: break
          // Cancel reordering if the gesture is not recognized or cancelled
          tableView.reloadData()
      }
  }
}


