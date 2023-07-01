//
//  SettingViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/28.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI
import SafariServices
import GoogleMobileAds

class SettingViewController: UIViewController {
  let maxGroup = 3
  let maxKeyword = 10
  
  lazy var realm:Realm = {
    return try! Realm()
  }()
  
  enum SettingSection: Int, CaseIterable {
    case app
    case other
  }
  
  enum AppType: Int, CaseIterable {
    case group
    case keyword
    case exceptPress
  }
  enum OtherType: Int, CaseIterable {
    case terms
    case policy
    case report
    case share
  }
  
  private var rewardedAd: GADRewardedAd?
  
  func loadRewardedAd() {
    let request = GADRequest()
    GADRewardedAd.load(withAdUnitID: Constants.googleADModRewardID,
                       request: request,
                       completionHandler: { [self] ad, error in
      if let error = error {
        print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        return
      }
      rewardedAd = ad
      rewardedAd?.fullScreenContentDelegate = self

      print("Rewarded ad loaded.")
    }
    )
  }
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    loadRewardedAd()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
}

extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let section = SettingSection(rawValue: section) else { return nil }
    switch section {
    case .app: return "APP"
    case .other: return "OTHER"
    }
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = SettingSection(rawValue: indexPath.section) else { return }
    switch section {
      
    case .app:
      guard let appType = AppType(rawValue: indexPath.row) else { return }
      switch appType {
      case .group:
        let alert = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CustomAlertViewController") { coder in
          CustomAlertViewController(coder: coder, head: "키워드 10개 지급", body: "광고를 시청하고 키워드 보상을 받으세요!")
        }
        alert.delegate = self
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: true)
        break
      case .keyword:
        break
      case .exceptPress:
        let vc = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(identifier: "ExceptPublisherViewController")
        navigationController?.pushViewController(vc, animated: true)
      }
    case .other:
      guard let otherType = OtherType(rawValue: indexPath.row) else { return }
      switch otherType {
      case .terms:
        let safariVC = SFSafariViewController(url: URL(string: Constants.infoURL)!)
        present(safariVC, animated: true, completion: nil)
      case .policy:
        let safariVC = SFSafariViewController(url: URL(string: Constants.privacyURL)!)
        present(safariVC, animated: true, completion: nil)
      case .report:
        if MFMailComposeViewController.canSendMail() {
          let compseVC = MFMailComposeViewController()
          compseVC.mailComposeDelegate = self
          compseVC.setToRecipients(["2x2isfor.gmail.com"])
          compseVC.setSubject("메시지제목")
          compseVC.setMessageBody("메시지컨텐츠", isHTML: false)
          self.present(compseVC, animated: true, completion: nil)
        }
        else {
          self.showSendMailErrorAlert()
        }
      case .share:
        Util.sharedInstance.showShareActivity(objectsToShare: [Constants.appDownloadURL] as AnyObject)
      }
    }
  }
  func showSendMailErrorAlert() {
    let sendMailErrorAlert = UIAlertController(title: "메일을 전송 실패", message: "아이폰 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .default) {
      (action) in
      print("확인")
    }
    sendMailErrorAlert.addAction(confirmAction)
    self.present(sendMailErrorAlert, animated: true, completion: nil)
  }
  
  func showRewardAd() {
    if let ad = rewardedAd {
      ad.present(fromRootViewController: self) {
        let reward = ad.adReward
        print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
        // TODO: Reward the user.
      }
    } else {
      print("Ad wasn't ready")
    }
  }
}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = SettingSection(rawValue: indexPath.section) else { return UITableViewCell() }
    let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
    var configuration = cell.defaultContentConfiguration()
    
    let font = UIFont.systemFont(ofSize: 13)
    configuration.textProperties.font = font
    configuration.secondaryTextProperties.font = font
    
    
    switch section {
    case .app:
      guard let appType = AppType(rawValue: indexPath.row) else { return UITableViewCell() }
      switch appType {
      case .group:
        let groupCount = realm.objects(GroupRealm.self).count
        configuration.text = "그룹"
        
        configuration.secondaryText = "\(groupCount) / \(maxGroup)"
        if groupCount < 2 {
          configuration.secondaryTextProperties.color = .systemGreen
        } else if groupCount < 3 {
          configuration.secondaryTextProperties.color = .systemYellow
        } else {
          configuration.secondaryTextProperties.color = .systemRed
        }
        configuration.image = UIImage(systemName: "rectangle.3.group")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      case .keyword:
        let keywordCount = realm.objects(KeywordRealm.self).count
        configuration.text = "키워드"
        
        configuration.secondaryText = "\(keywordCount) / \(maxKeyword)"
        if keywordCount < 5 {
          configuration.secondaryTextProperties.color = .systemGreen
        } else if keywordCount < 9 {
          configuration.secondaryTextProperties.color = .systemYellow
        } else {
          configuration.secondaryTextProperties.color = .systemRed
        }
        configuration.image = UIImage(systemName: "newspaper")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      case .exceptPress:
        let exceptpressCount = self.realm.objects(exceptNews.self).count
        configuration.text = "제외언론사"
        configuration.secondaryText = "\(exceptpressCount)"
        configuration.image = UIImage(systemName: "selection.pin.in.out")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      }
    case .other:
      guard let otherType = OtherType(rawValue: indexPath.row) else { return UITableViewCell() }
      switch otherType {
      case .policy:
        configuration.text = "개인정보 처리방침"
        configuration.image = UIImage(systemName: "doc.viewfinder")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      case .terms:
        configuration.text = "이용약관"
        configuration.image = UIImage(systemName: "doc.append")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      case .report:
        configuration.text = "문의하기"
        configuration.image = UIImage(systemName: "exclamationmark.bubble")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      case .share:
        configuration.text = "공유"
        configuration.image = UIImage(systemName: "square.and.arrow.up")?.withTintColor(.label, renderingMode: .alwaysOriginal)
      }
      cell.accessoryType = .disclosureIndicator
    }
    cell.contentConfiguration = configuration
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    SettingSection.allCases.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = SettingSection(rawValue: section) else { return 0 }
    switch section {
    case .app: return AppType.allCases.count
    case .other: return OtherType.allCases.count
    }
  }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}


extension SettingViewController: CustomAlertDelegate {
  func onOk() {
    showRewardAd()
  }
}

extension SettingViewController: GADFullScreenContentDelegate {
  /// Tells the delegate that the ad failed to present full screen content.
  func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("Ad did fail to present full screen content.")
  }

  /// Tells the delegate that the ad will present full screen content.
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad will present full screen content.")
  }

  /// Tells the delegate that the ad dismissed full screen content.
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad did dismiss full screen content.")
  }

}
