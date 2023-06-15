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
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}
