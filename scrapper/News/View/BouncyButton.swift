//
//  BouncyButton.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/29.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import UIKit

class BouncyButton: UIButton {
  private var originalTransform: CGAffineTransform!
      
      override init(frame: CGRect) {
          super.init(frame: frame)
          setupAnimation()
      }
      
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          setupAnimation()
      }
      
      private func setupAnimation() {
          originalTransform = transform
          
          let animation = CAKeyframeAnimation(keyPath: "transform.scale")
          animation.values = [1.0, 0.95, 1.0]
          animation.keyTimes = [0, 0.5, 1.0]
          animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
          animation.duration = 0.5
          animation.repeatCount = .infinity
          layer.add(animation, forKey: "scaleAnimation")
      }
      
      override func removeFromSuperview() {
          super.removeFromSuperview()
          layer.removeAnimation(forKey: "scaleAnimation")
      }
}
