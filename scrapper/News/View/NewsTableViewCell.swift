//
//  NewsTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
  @IBOutlet weak var unread: UILabel!
  @IBOutlet weak var selectImage: UIImageView!
  var isSelectMode: Bool = false
  @IBOutlet weak var publishTime: UILabel!
  @IBOutlet weak var title: UILabel!
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    guard isSelectMode else {
      return
    }
    
    if selected {
      selectImage.image = UIImage(systemName: "circle.inset.filled")
    } else {
      selectImage.image = UIImage(systemName: "circle.dashed")
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    selectImage.isHidden = true
  }
  
  func configure(news: News, lastReadTimestamp: TimeInterval) {
    title.text = news.title.htmlStripped.replacingOccurrences(of: "&squot;", with: "\'")
    publishTime.text = Util.sharedInstance.naverTimeFormatToNormal(date: news.publishTime)
    unread.isHidden = news.publishTimestamp ?? 0 > lastReadTimestamp
    unread.isHidden = true
  }
}
