//
//  KeywordTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class KeywordTableViewCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var exceptionLabel: UILabel!
  
  @IBOutlet weak var unreads: UILabel!
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    unreads.layer.masksToBounds = true
    unreads.layer.cornerRadius = unreads.frame.width / 2
  }
  func config(keyword: KeywordRealm) {
    titleLabel.text = keyword.keyword
    exceptionLabel.text = "- " + keyword.exceptionKeyword
    exceptionLabel.isHidden = keyword.exceptionKeyword.isEmpty
    unreads.isHidden = true
  }
}
