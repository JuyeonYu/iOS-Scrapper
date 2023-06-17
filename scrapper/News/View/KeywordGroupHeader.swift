//
//  KeywordGroupHeader.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/17.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

protocol KeywordGroupHeaderDelegate: AnyObject {
  func onUp(section: Int)
  func onDown(section: Int)
  func onDelete(section: Int)
}

class KeywordGroupHeader: UITableViewHeaderFooterView {
  @IBAction func onShowContent(_ sender: Any) {
    showEdit(false)
    showContent(true)
  }
  @IBAction func onDelete(_ sender: Any) {
    guard let section else { return }
    showEdit(false)
    showContent(true)
    delegate?.onDelete(section: section)
  }
  @IBOutlet weak var onEdit: UIButton!
  @IBOutlet weak var delete: UIButton!
  var section: Int?
  @IBAction func onMinus(_ sender: Any) {
    showEdit(true)
    showContent(false)
  }
  @IBOutlet weak var minus: UIButton!
  weak var delegate: KeywordGroupHeaderDelegate?
  @IBOutlet weak var index: UIView!
  
  @IBAction func onup(_ sender: Any) {
    guard let section else { return }
    delegate?.onUp(section: section)
  }
  @IBAction func onDown(_ sender: Any) {
    guard let section else { return }
    delegate?.onDown(section: section)
  }
  @IBOutlet weak var group: UILabel!

  @IBOutlet weak var count: UILabel!
  @IBOutlet weak var down: UIButton!
  @IBOutlet weak var up: UIButton!
  fileprivate func commonSetting() {
    up.setTitle("", for: .normal)
    down.setTitle("", for: .normal)
    showEdit(false)
    showReorder(false)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    commonSetting()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    commonSetting()
  }
  
  func showContent(_ show: Bool) {
    [self.minus, self.group, self.count, self.up, self.down].forEach {
      $0?.isHidden = !show
    }
  }
  
  func showEdit(_ show: Bool) {
    UIView.animate(withDuration: 0.25) {
      self.delete.isHidden = !show
    }
  }
  func showReorder(_ show: Bool, isDefault: Bool = false) {
    let contentButtons = isDefault ? [up, down] : [minus, up, down]
    contentButtons.forEach {
      $0?.isHidden = !show
    }
  }
  
  func configure(group: GroupRealm, keywordCount: Int, isEditing: Bool) {
    self.group.text = (group.name.isEmpty ? "기본" : group.name)
    count.text = "(\(String(keywordCount)))"
    showReorder(isEditing, isDefault: group.name.isEmpty)
  }
}
