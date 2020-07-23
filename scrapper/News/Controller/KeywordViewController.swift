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
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    let keywordCellID = "KeywordTableViewCell"
    let newsListViewControllerID = "NewsListViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation setting
        self.navigationItem.title = NSLocalizedString("Keyword", comment: "")
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add,
                                                   target: self,
                                                   action: #selector(didTapAddKeywordButton))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // Tableview setting
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
        
        let nibName = UINib(nibName: keywordCellID, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: keywordCellID)
        
        // get data for tableview
        
        if realm.objects(KeywordRealm.self).count == 0 {
            didTapAddKeywordButton()
        }
    }
        
    @objc func didTapAddKeywordButton() {
        let alert = UIAlertController(title: NSLocalizedString("Keyword", comment: ""),
                                      message: NSLocalizedString("Please enter keyword which make you interting", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = NSLocalizedString("Please enter keyword which make you interting", comment: "")
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        let ok = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (_) in
            let text = alert.textFields?[0].text

            guard let keyword = text else {
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
            keywordRealm.keyword = text!
            keywordRealm.userID = UserDefaultsManager.getUserID()
            try! self.realm.write {
                self.realm.add(keywordRealm)
            }
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
        
        let vc = self.storyboard?.instantiateViewController(identifier: newsListViewControllerID) as! NewsListViewController
        vc.navigationItem.title = keyword // 뉴스 페이지 제목 설정
        vc.searchKeyword = keyword
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    fileprivate func setTimePicker(keyword: String) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 250)
        let pickerView = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        pickerView.datePickerMode = .time
        vc.view.addSubview(pickerView)
        
        let editRadiusAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.timeStyle = DateFormatter.Style.short
            
            let date = pickerView.date
            let strTime = date.dateStringWith(strFormat: "HH:mm")
            print(keyword, strTime)
            
            let keywordRealm = self.realm.objects(KeywordRealm.self).filter("keyword = '\(keyword)'").first
            try! self.realm.write {
                keywordRealm?.alarmTime = date
            }
        }))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let keyword = self.realm.objects(KeywordRealm.self)[indexPath.row]

            // realm에서 먼저 삭제 한다.
            try! self.realm.write {
                self.realm.delete(keyword)
            }
            tableView.reloadData()
            success(true)
        })
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let alarmAction = UIContextualAction(style: .normal,
                                             title: "",
                                             handler: {(ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.setTimePicker(keyword: Array(self.realm.objects(KeywordRealm.self))[indexPath.row].keyword)
            success(true)
        })
        
        alarmAction.image = UIImage(systemName: "alarm")
        return UISwipeActionsConfiguration(actions:[deleteAction, alarmAction])
    }
}

extension KeywordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if realm.objects(KeywordRealm.self).count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("Why don't you add some new keyword?", comment: ""))
        } else {
            self.tableView.restore()
        }
        return realm.objects(KeywordRealm.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: keywordCellID, for: indexPath) as! KeywordTableViewCell
        let row = indexPath.row
        let keywordList = Array(realm.objects(KeywordRealm.self))
        let keyword = keywordList[row].keyword
        cell.titleLabel.text = keyword
        return cell
    }
}

extension Date {
 func dateStringWith(strFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = strFormat
        return dateFormatter.string(from: self)
    }
}
