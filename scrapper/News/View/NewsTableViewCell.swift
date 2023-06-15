//
//  NewsTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var publishTime: UILabel!
  @IBOutlet weak var title: UILabel!
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}
