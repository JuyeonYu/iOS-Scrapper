//
//  SettingViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/28.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  
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
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
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
}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = SettingSection(rawValue: indexPath.section) else { return UITableViewCell() }
    let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
    var configuration = cell.defaultContentConfiguration()
    
    let font = UIFont.systemFont(ofSize: 13) // Change the font size to your desired value
    configuration.textProperties.font = font
    configuration.secondaryTextProperties.font = font


    switch section {
    case .app:
      guard let appType = AppType(rawValue: indexPath.row) else { return UITableViewCell() }
      switch appType {
      case .group:
        configuration.text = "그룹"
        configuration.secondaryText = "Detail"
        configuration.image = UIImage(systemName: "rectangle.3.group")
      case .keyword:
        configuration.text = "키워드"
        configuration.secondaryText = "Detail"
        configuration.image = UIImage(systemName: "newspaper")
      case .exceptPress:
        configuration.text = "제외언론사"
        configuration.secondaryText = "Detail"
        configuration.image = UIImage(systemName: "selection.pin.in.out")
      }
    case .other:
      guard let otherType = OtherType(rawValue: indexPath.row) else { return UITableViewCell() }
      switch otherType {
      case .policy:
        configuration.text = "개인정보 처리방침"
        configuration.image = UIImage(systemName: "doc.viewfinder")
      case .terms:
        configuration.text = "이용약관"
        configuration.image = UIImage(systemName: "doc.append")
      case .report:
        configuration.text = "문의하기"
        configuration.image = UIImage(systemName: "exclamationmark.bubble")
      case .share:
        configuration.text = "공유"
        configuration.image = UIImage(systemName: "square.and.arrow.up")
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
