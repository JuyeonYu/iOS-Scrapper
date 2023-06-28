//
//  PayViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/29.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit

class PayViewController: UIViewController {

  @IBOutlet weak var pay: BouncyButton!
  override func viewDidLoad() {
        super.viewDidLoad()
    
    // 애니메이션 설정
            
        // Do any additional setup after loading the view.
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    let animationDuration = 0.5 // 애니메이션 지속 시간 (초)
//    let scaleFactor: CGFloat = 97/100 // 크기 변화 비율
//
//    UIView.animate(withDuration: animationDuration, delay: 0, options: [.repeat, .autoreverse], animations: {
//        self.pay.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//    }, completion: nil)
    let animationDuration = 1.5 // 애니메이션 지속 시간 (초)
    let scaleFactor: CGFloat = 1.05 // 크기 변화 비율
    let damping: CGFloat = 0.2 // 감쇠 계수

    UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: [.repeat, .autoreverse], animations: {
        // 스케일 애니메이션
        self.pay.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    }) { (_) in
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: [.repeat, .autoreverse], animations: {
            // 튕김 애니메이션
            self.pay.transform = .identity // 원래 크기로 돌아오기 위해 transform을 .identity로 설정
        })
    }


  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
