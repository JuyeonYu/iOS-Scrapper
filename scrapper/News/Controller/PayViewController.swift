//
//  PayViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/29.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import AVFoundation

class PayViewController: UIViewController {
  @IBAction func onYearlyPay(_ sender: Any) {
    yearlyPay.setTitle("30,000원 / 연", for: .normal)
    monthlyPay.setTitle("3,300원 / 월", for: .normal)
    
    monthlyPay.layer.borderColor = UIColor(named: "Theme")?.cgColor
    yearlyPay.layer.borderColor = UIColor.gray.cgColor
//    if #available(iOS 15.0, *) {
//
//      yearlyPay.configuration = .tinted()
//      monthlyPay.configuration = .gray()
//    } else {
//      yearlyPay.backgroundColor = UIColor(named: "Theme")
//      monthlyPay.backgroundColor = UIColor.gray
//    }
    
  }
  @IBAction func onMonthlyPay(_ sender: Any) {
    
    yearlyPay.setTitle("30,000원 / 연", for: .normal)
    monthlyPay.setTitle("3,300원 / 월", for: .normal)
    
//    monthlyPay.layer.borderColor = UIColor.gray.cgColor
//    yearlyPay.layer.borderColor = UIColor(named: "Theme")?.cgColor
//    if #available(iOS 15.0, *) {
//
//      yearlyPay.configuration = .gray()
//      monthlyPay.configuration = .tinted()
//    } else {
//      yearlyPay.backgroundColor = UIColor.gray
//      monthlyPay.backgroundColor = UIColor(named: "Theme")
//    }
    
  }
  @IBOutlet weak var yearlyPay: UIButton!
  @IBOutlet weak var monthlyPay: UIButton!
  var playerAV: AVPlayer!
  @IBAction func onClose(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBOutlet weak var playerParent: UIView!
  @IBOutlet weak var pay: BouncyButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    pay.layer.masksToBounds = true
    pay.layer.cornerRadius = 25
    
    [monthlyPay, yearlyPay].forEach {
      $0?.layer.borderWidth = 1
      $0?.layer.cornerRadius = 20
      $0?.backgroundColor = .clear
    }
    
    guard let path = Bundle.main.path(forResource: "paywall\(Int.random(in: 1...3))", ofType:"mp4") else {
      debugPrint("video.m4v not found")
      return
    }
    playerAV = AVPlayer(url: URL(fileURLWithPath: path))
    playerAV.play()
    
    let playerLayerAV = AVPlayerLayer(player: playerAV)
    playerLayerAV.frame = playerParent.bounds
    playerParent.layer.addSublayer(playerLayerAV)
    playerLayerAV.videoGravity = .resizeAspectFill
    playerLayerAV.isOpaque = true

    playerLayerAV.opacity = 1
    loopVideo(videoPlayer: playerAV)
  }
  
  func loopVideo(videoPlayer: AVPlayer) {
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
        self.playerAV.seek(to: CMTime.zero)
        self.playerAV.play()
      }
  }

  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
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
