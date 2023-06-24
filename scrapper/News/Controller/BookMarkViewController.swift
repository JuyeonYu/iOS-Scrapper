//
//  BookMarkViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/14.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices
import GoogleMobileAds

class BookMarkViewController: UIViewController {
  var selectedNewsRows: Set<Int> = [] {
    didSet {
      [share, delete].forEach { $0?.isEnabled = !(selectedNewsRows.isEmpty) }
    }
  }
  var isSelectMode: Bool = false {
    didSet {
      tableView.reloadData()
      if !isSelectMode {
        [share, delete].forEach { $0?.isEnabled = false }
      }
      if isSelectMode {
        edit.title = "취소"
        
      } else {
        edit.title = "선택"
      }
    }
  }
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  @IBOutlet weak var bannerView: GADBannerView!
  
  var filteredNews: [BookMarkNewsRealm] = []
  var dataList: [BookMarkNewsRealm] = []
  
  @IBOutlet weak var delete: UIBarButtonItem!
  @IBOutlet weak var share: UIBarButtonItem!
  @IBOutlet weak var edit: UIBarButtonItem!
  @IBAction func onEdit(_ sender: Any) {
    self.isSelectMode.toggle()
    
  }
  @IBAction func onShare(_ sender: Any) {
    Util.sharedInstance.showShareActivity(news: Array(realm.objects(BookMarkNewsRealm.self)))
  }
  @IBAction func onDelete(_ sender: Any) {
    let alert = UIAlertController(title: "삭제", message: "선택한 기사가 삭제됩니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
      try! self.realm.write {
        let selectedRows = Array(self.selectedNewsRows).sorted(by: >)
        selectedRows.forEach {
          self.realm.delete(Array(self.realm.objects(BookMarkNewsRealm.self))[$0])
        }
      }
      self.isSelectMode = false
      self.tableView.reloadData()
    })
    present(alert: alert)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    [share, delete].forEach { $0?.isEnabled = !($0!.isEnabled) }
    /*
     1. realm에서 북마크된 뉴스 목록을 가져온다.
     2. tableview에 1에서 가져온 목록을 뿌린다.
     3. 북마크 삭제시 realm에서도 삭제해준다.
     3. 북마크 삭제시 realm에서도 삭제해준다.
     */
    tableView.allowsMultipleSelection = true
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView() // 빈 셀에 하단 라인 없앰
    
    searchBar.delegate = self
    searchBar.placeholder = NSLocalizedString("Please search news", comment: "")
    
    
    self.navigationController?.tabBarController?.delegate = self
    
    // MARK: - Navigation setting
    self.navigationItem.title = NSLocalizedString("Bookmark", comment: "")
    tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
    bannerView.adUnitID = Constants.googleADModBannerID
    bannerView.rootViewController = self
    bannerView.load(GADRequest())
  }
}

extension BookMarkViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard !isSelectMode else {
      selectedNewsRows.insert(indexPath.row)
      return
    }
    //        뉴스리스트 중 하나를 누르면 그 뉴스를 읽은 뉴스로 저장해야함
    let row = indexPath.row
    let news = Array(realm.objects(BookMarkNewsRealm.self))[row]
    
    let readNewsRealm = ReadNewsRealm()
    readNewsRealm.title = news.title
    
    if realm.objects(ReadNewsRealm.self).filter("title = '\(news.title)'").isEmpty {
      try! realm.write({
        realm.add(readNewsRealm)
      })
    }
    
    let safariVC = SFSafariViewController(url: URL(string: realm.objects(BookMarkNewsRealm.self)[row].urlString)!)
    safariVC.delegate = self
    present(safariVC, animated: true, completion: nil)
  }
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard !isSelectMode else {
      if selectedNewsRows.contains(indexPath.row) {
        selectedNewsRows.remove(indexPath.row)
      }
      return
    }
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive,
                                          title:  "삭제",
                                          handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      let news = self.realm.objects(BookMarkNewsRealm.self)[indexPath.row]
      
      // realm에서 먼저 삭제 한다.
      try! self.realm.write {
        self.realm.delete(news)
      }
      
      tableView.reloadData()
      success(true)
    })
    
    let shareAction = UIContextualAction(style: .normal,
                                         title:  NSLocalizedString("share", comment: ""),
                                         handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
      let row = indexPath.row
      let newsTitle = self.realm.objects(BookMarkNewsRealm.self)[row].title
      let newsURL = self.realm.objects(BookMarkNewsRealm.self)[row].urlString
      let newsArray = [newsTitle, newsURL]
      
      let activityViewController = UIActivityViewController(activityItems: newsArray, applicationActivities: nil)
      activityViewController.popoverPresentationController?.sourceView = self.view
      self.present(activityViewController, animated: true, completion: nil)
      
      success(true)
    })
    return UISwipeActionsConfiguration(actions:[deleteAction, shareAction])
  }
}

extension BookMarkViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchBar.text != "" && searchBar.text != nil && searchBar.isFirstResponder {
      return filteredNews.count
    } else {
      return realm.objects(BookMarkNewsRealm.self).count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
    let row = indexPath.row
    cell.isSelectMode = isSelectMode
    if searchBar.text != "" && searchBar.isFirstResponder {
      dataList = filteredNews
    } else {
      let bookmarkNewsList = Array(realm.objects(BookMarkNewsRealm.self))
      dataList = bookmarkNewsList
    }
    cell.title.text = dataList[row].title.stripOutHtml()?.replacingOccurrences(of: "&squot;", with: "\'")
    cell.publishTime.text = Util.sharedInstance.naverTimeFormatToNormal(date: dataList[row].publishTime)
    cell.selectImage.isHidden = !isSelectMode
    
    DispatchQueue.main.async {
      if !self.realm.objects(ReadNewsRealm.self).filter("title = '\(self.dataList[row].title)'").isEmpty {
        print("이미 읽은 뉴스 기사 제목 \(self.dataList[row].title)")
        cell.title.textColor = UIColor.lightGray
        cell.publishTime.textColor = UIColor.lightGray
      } else {
        cell.title.textColor = UIColor.red
        cell.publishTime.textColor = UIColor.red
      }
    }
    return cell
  }
}

extension BookMarkViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if tabBarController.selectedIndex == 1 {
      self.tableView.reloadData()
    }
  }
}

extension BookMarkViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredNews.removeAll()
    
    for news in realm.objects(BookMarkNewsRealm.self) {
      if news.title.contains(searchText) {
        print("검색된 뉴스:  \(news.title)")
        filteredNews.append(news)
      }
    }
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar.endEditing(true)
  }
}

extension BookMarkViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    self.tableView.reloadData()
  }
}
