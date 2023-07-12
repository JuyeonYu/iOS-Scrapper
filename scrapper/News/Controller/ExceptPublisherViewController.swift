//
//  ExceptPublisherViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/17.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class ExceptPublisherViewController: UIViewController {
  private var interstitial: GADInterstitialAd?

  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  var selectedPress: Set<String> = []
  
  @IBOutlet weak var tableView: UITableView!
  fileprivate func loadAd() {
    let request = GADRequest()
    
    GADInterstitialAd.load(withAdUnitID: Constants.googleADModFullPageID,
                           request: request,
                           completionHandler: { [self] ad, error in
      if let error = error {
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        return
      }
      interstitial = ad
      interstitial?.fullScreenContentDelegate = self
    })
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Task {
      if await !IAPManager.isPro() {
        loadAd()
      }
    }
    
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
    if interstitial != nil {
      interstitial!.present(fromRootViewController: self)
    }
    let press = Constants.press[indexPath.row]
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
        news.domain = Constants.domain[press] ?? ""
        realm.add(news)
      })
    }
    
    cell.contentConfiguration = content
  }
}

extension ExceptPublisherViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
    let press = Constants.press[indexPath.row]
    var content = cell.defaultContentConfiguration()
    content.text = press
    if selectedPress.contains(press) {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    cell.contentConfiguration = content
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    Constants.press.count
  }
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    "선택한 언론사의 뉴스는 걸러냅니다."
  }
  //  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
  //    "기타 선택 시 선택되지 않는 언론사의 뉴스만 볼 수 있습니다."
  //  }
}

extension ExceptPublisherViewController: GADFullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    loadAd()
  }
}
