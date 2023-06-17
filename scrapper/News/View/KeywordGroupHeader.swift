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
  var section: Int?
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

  @IBOutlet weak var down: UIButton!
  @IBOutlet weak var up: UIButton!
  override func awakeFromNib() {
    super.awakeFromNib()
    up.setTitle("", for: .normal)
    down.setTitle("", for: .normal)
  }
  
  func configure(group: GroupRealm, isEditing: Bool) {
    [up, down].forEach { $0?.isHidden = !isEditing }
    self.group.text = group.name.isEmpty ? "그룹없음" : group.name
  }
}
