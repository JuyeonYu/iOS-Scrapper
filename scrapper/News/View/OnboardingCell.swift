//
//  OnboardingCell.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/01.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
  @IBOutlet weak var head: UILabel!
  
  @IBOutlet weak var foot: UILabel!
//  @IBOutlet weak var thumbnail: UIImageView!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configure(item: OnboardingItem) {
    head.text = item.head
//    thumbnail.image = UIImage(systemName: item.imageName)
    foot.text = item.foot
  }

}
