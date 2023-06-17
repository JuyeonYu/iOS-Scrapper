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
}

class KeywordGroupHeader: UITableViewHeaderFooterView {
  @IBAction func onShowContent(_ sender: Any) {
    showEdit(false)
    showContent(true)
  }
  @IBOutlet weak var onDelete: UIButton!
  @IBOutlet weak var onEdit: UIButton!
  @IBOutlet weak var delete: UIButton!
  @IBOutlet weak var eidt: UIButton!
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
  override func awakeFromNib() {
    super.awakeFromNib()
    up.setTitle("", for: .normal)
    down.setTitle("", for: .normal)
    showEdit(false)
    showReorder(false)
  }
  
  func showContent(_ show: Bool) {
    [self.minus, self.group, self.count].forEach {
      $0?.isHidden = !show
    }
  }
  
  func showEdit(_ show: Bool) {
    UIView.animate(withDuration: 0.25) {
      [self.eidt, self.delete].forEach {
        $0?.isHidden = !show
      }
    }
  }
  func showReorder(_ show: Bool) {
    [minus, up, down].forEach {
      $0?.isHidden = !show
    }
  }
  
  func configure(group: GroupRealm, keywordCount: Int, isEditing: Bool) {
    self.group.text = (group.name.isEmpty ? "그룹없음" : group.name)
    count.text = "(\(String(keywordCount)))"
    showReorder(isEditing)
  }
}
