//
//  AddGroupViewController.swift
//  scrapper
//
//  Created by  유 주연 on 11/23/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import Lottie

enum AddType {
  case group
  case keyword
  
  var header: String {
    switch self {
    case .group: return "새 그룹을 추가해보세요"
    case .keyword: return "새 키워드를 추가해보세요"
    }
  }
}

class AddGroupViewController: UIViewController {
  var addType: AddType = .group
  @IBOutlet weak var header: UILabel!
  @IBOutlet weak var error: UILabel!
  
  @IBOutlet weak var add: UIButton!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textField2: UITextField!
  lazy var realm: Realm = {
    return try! Realm()
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    header.text = addType.header
    
    textField.becomeFirstResponder()
    textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    textField.layer.borderWidth = 1
    textField2.layer.borderWidth = 1
    setEmptyStatus()
    
    switch addType {
    case .group:
      textField2.isHidden = true
      textField.placeholder = "그룹을 입력해주세요"
    case .keyword:
      textField.placeholder = "키워드를 입력해주세요"
      textField2.placeholder = "(옵션)제외할 키워드를 등록해주세요"
    }
  }
  
  private func setEmptyStatus() {
    add.backgroundColor = .systemGray3
    textField.layer.borderColor = UIColor.systemGray3.cgColor
    textField2.layer.borderColor = UIColor.systemGray3.cgColor
    add.isEnabled = false
  }
    
  private func checkValid() {
    guard !(textField.text ?? "").isEmpty else {
      setEmptyStatus()
      return
    }
    
    let validCondition: Bool
    
    switch addType {
    case .group: validCondition = (self.realm.objects(GroupRealm.self).filter("name = '\(String(describing: textField.text ?? ""))'").isEmpty)
    case .keyword: validCondition = (self.realm.objects(KeywordRealm.self).filter("keyword = '\(String(describing: textField.text ?? ""))'").isEmpty)
    }
    
    guard validCondition else {
      textField.layer.borderColor = UIColor.red.cgColor
      error.isHidden = false
      error.text = "이미 존재하는 키워드입니다."
      add.backgroundColor = .systemGray3
      add.isEnabled = false
      return
    }
    error.isHidden = true
    if textField.text?.isEmpty ?? true {
      setEmptyStatus()
    } else {
      add.isEnabled = true
      add.backgroundColor = UIColor(named: "Theme")
      textField.layer.borderColor = UIColor(named: "Theme")?.cgColor
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    checkValid()
  }
  @IBAction func onAdd(_ sender: Any) {
    switch addType {
    case .group:
      saveGroup()
      navigationController?.popViewController(animated: false)
    case .keyword:
      saveKeyword()
    }
    
  }
  
  private func saveGroup() {
    let groupRealm = GroupRealm()
    groupRealm.name = textField.text!
    groupRealm.id = UUID()
    groupRealm.timestamp = Date().timeIntervalSince1970
    try! self.realm.write {
      self.realm.add(groupRealm)
    }
  }
  
  private func saveKeyword() {
    if self.realm.objects(GroupRealm.self).count == 1 {
      let keywordRealm = KeywordRealm()
      keywordRealm.keyword = textField.text!
      keywordRealm.exceptionKeyword = textField2.text!
      keywordRealm.timestamp = Date().timeIntervalSince1970
      
      if let noneGroup = realm.objects(GroupRealm.self).filter({ $0.name == ""}).first {
        keywordRealm.gourpId = noneGroup.id
      } else {
        keywordRealm.gourpId = UUID()
      }
      keywordRealm.hasNews = true
      try! self.realm.write {
        self.realm.add(keywordRealm)
      }
      FirestoreManager().upsert(keyword: KeywordFirestore(keywordRealm: keywordRealm))
      navigationController?.popViewController(animated: false)
    } else {
      let vc = SelectGroupViewController(nibName: "SelectGroupViewController", bundle: nil)
      vc.keyword = textField.text!
      vc.exceptionKeyword = textField2.text
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}
