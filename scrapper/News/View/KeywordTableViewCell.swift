//
//  KeywordTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

protocol KeywordTableViewCellDelegate: AnyObject {
  func onNoti(indexPath: IndexPath)
}

class KeywordTableViewCell: UITableViewCell {
  @IBOutlet weak var noti: UIButton!
  @IBAction func onNoti(_ sender: Any) {
    guard let indexPath else { return }
    delegate?.onNoti(indexPath: indexPath)
  }
  weak var delegate: KeywordTableViewCellDelegate?
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var exceptionLabel: UILabel!
  var indexPath: IndexPath?
  
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
    unreads.isHidden = false
    noti.setImage(.init(systemName: keyword.notiEnabled ? "bell.fill" : "bell.slash.fill"), for: .normal)
  }
}
