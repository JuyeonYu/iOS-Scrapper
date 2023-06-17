//
//  ExceptPublisherViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/17.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import RealmSwift

class ExceptPublisherViewController: UIViewController {
  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  var selectedPress: Set<String> = []
  let press: [String] = ["KBS", "MBC", "SBS", "경향신문", "뉴스1", "뉴시스", "동아일보", "매일경제", "머니투데이", "서울신문", "아시아경제", "엑스포츠뉴스", "연합뉴스", "이데일리", "조선일보", "중앙일보", "티빙", "파이낸셜뉴스", "한겨레", "한국경제", "기타"]
  let domain: [String: String] = [
    "조선일보": "chosun.com", "매일경제": "mk.co.kr", "연합뉴스": "yna.co.kr", "뉴시스": "newsis.com", "동아일보": "donga.com", "한국경제": "hankyung", "경향신문": "khan.co.kr", "머니투데이": "mt.co.kr", "중앙일보": "joongang.co.kr", "이데일리": "edaily.co.kr", "KBS": "kbs.co.kr", "뉴스1": "news1.kr", "SBS": "sbs.co.kr", "MBC": "imbc.com", "한겨레": "hani.co.kr", "파이낸셜뉴스": "fnnews.com", "아시아경제": "asiae.co.kr", "서울신문": "seoul.co.kr", "엑스포츠뉴스": "xportsnews.com", "티빙": "tving.com"
  ]
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    realm.objects(exceptNews.self).forEach {
      selectedPress.insert($0.press)
    }
  }
}

extension ExceptPublisherViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    if #available(iOS 14.0, *) {
      let press = press[indexPath.row]
      var content = cell.defaultContentConfiguration()
      content.text = press
      
      if selectedPress.contains(press) {
        cell.accessoryType = .none
        selectedPress.remove(press)
        
        realm.objects(exceptNews.self).filter { $0.press == press }.forEach { press in
          try! realm.write({
            realm.delete(press)
          })
        }
      } else {
        cell.accessoryType = .checkmark
        selectedPress.insert(press)
        try! realm.write({
          let news = exceptNews()
          news.press = press
          realm.add(news)
        })
      }
      
      cell.contentConfiguration = content
    } else {
      // Fallback on earlier versions
    }
  }
}

extension ExceptPublisherViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
    let press = press[indexPath.row]
    if #available(iOS 14.0, *) {
      var content = cell.defaultContentConfiguration()
      content.text = press
      if selectedPress.contains(press) {
        cell.accessoryType = .checkmark
      } else {
        cell.accessoryType = .none
      }
      cell.contentConfiguration = content
    } else {
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    press.count
  }
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    "선택한 언론사의 뉴스는 걸러냅니다."
  }
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    "기타 선택 시 선택되지 않는 언론사의 뉴스만 볼 수 있습니다."
  }
}
