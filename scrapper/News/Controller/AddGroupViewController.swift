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

class AddGroupViewController: UIViewController {
  @IBOutlet weak var error: UILabel!
  
  @IBOutlet weak var add: UIButton!
  @IBOutlet weak var textField: UITextField!
  lazy var realm: Realm = {
    return try! Realm()
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    textField.becomeFirstResponder()
    textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    textField.layer.borderWidth = 1

    setEmptyStatus()
  }
  
  private func setEmptyStatus() {
    add.backgroundColor = .systemGray3
    textField.layer.borderColor = UIColor.systemGray3.cgColor
    add.isEnabled = false
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    guard !(textField.text ?? "").isEmpty else {
      setEmptyStatus()
      return
    }
    guard (self.realm.objects(GroupRealm.self).filter("name = '\(String(describing: textField.text ?? ""))'").isEmpty) else {
      textField.layer.borderColor = UIColor.red.cgColor
      error.isHidden = false
      error.text = "이미 존재하는 그룹입니다."
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
  @IBAction func onAdd(_ sender: Any) {
    let groupRealm = GroupRealm()
    groupRealm.name = textField.text!
    groupRealm.id = UUID()
    groupRealm.timestamp = Date().timeIntervalSince1970
    try! self.realm.write {
      self.realm.add(groupRealm)
    }
    navigationController?.popViewController(animated: false)
  }
}
