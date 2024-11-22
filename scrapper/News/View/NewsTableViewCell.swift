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
      selectImage.image = UIImage(systemName: "circle.inset.filled")?.withRenderingMode(.alwaysTemplate)
      selectImage.tintColor = UIColor(named: "Theme")!
    } else {
      selectImage.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
      selectImage.tintColor = UIColor(named: "Theme")!
    }
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    selectImage.isHidden = true
    unread.layer.masksToBounds = true
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    unread.layer.cornerRadius = unread.frame.width / 2
  }
  
  func configure(news: News, isNew: Bool) {
    self.title.text = news.title
      .replacingOccurrences(of: "&squot;", with: "\'")
      .replacingOccurrences(of: "<b>", with: "")
      .replacingOccurrences(of: "</b>", with: "")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&lt;", with: "<")
      .replacingOccurrences(of: "&gt;", with: ">")
    self.publishTime.text = Util.sharedInstance.naverTimeFormatToNormal(date: news.publishTime)
    self.unread.isHidden = !isNew
  }
  
  func configure(group: GroupRealm) {
    isSelectMode = true
    selectImage.isHidden = false
    title.text = group.name
    publishTime.isHidden = true
    unread.isHidden = true
  }
}
