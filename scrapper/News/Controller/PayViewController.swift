//
//  PayViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/06/29.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit

class PayViewController: UIViewController {
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBAction func onRestore(_ sender: Any) {
    do {
      if #available(iOS 15.0, *) {
        Task {
          try await AppStore.sync()
        }
        
      } else {
        // Fallback on earlier versions
      }
    } catch {
      print(error)
    }
    
  }
  @IBAction func onYearlyPay(_ sender: Any) {
    monthlyPay.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    monthlyPay.layer.borderColor = UIColor.lightGray.cgColor
    
    yearlyPay.backgroundColor = UIColor(named: "Theme")?.withAlphaComponent(0.3)
    yearlyPay.layer.borderColor = UIColor(named: "Theme")?.cgColor
    payProductId = productIds[0]
  }
  @IBAction func onMonthlyPay(_ sender: Any) {
    monthlyPay.backgroundColor = UIColor(named: "Theme")?.withAlphaComponent(0.3)
    monthlyPay.layer.borderColor = UIColor(named: "Theme")?.cgColor
    
    yearlyPay.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    yearlyPay.layer.borderColor = UIColor.lightGray.cgColor
    payProductId = productIds[1]
  }
  let productIds = ["year", "com.haar.scrap.month"]
  var payProductId = "year"
  @IBAction func onPay(_ sender: Any) {
      indicator.isHidden = false
      indicator.startAnimating()
      let productIds = ["year", "com.haar.scrap.month"]
      
      Task {
          do {
              if #available(iOS 15.0, *) {
                  let products = try await Product.products(for: [payProductId])
                  let result = try await products[0].purchase()
                  switch result {
                  case let .success(.verified(transaction)):
                      await transaction.finish()
                      DispatchQueue.main.async {
                          self.dismiss(animated: true)
                      }
                  case let .success(.unverified(_, error)):
                      break
                  case .pending, .userCancelled: break
                  }
              } else {
                  // Fallback on earlier versions
              }
          } catch {
              // Handle any errors here
          }
          
          DispatchQueue.main.async {
              self.indicator.isHidden = true
          }
      }
  }

  @IBOutlet weak var yearlyPay: UIButton!
  @IBOutlet weak var monthlyPay: UIButton!
  var playerAV: AVPlayer!
  @IBAction func onClose(_ sender: Any) {
    Task {
      if #available(iOS 15.0, *) {
        for await result in Transaction.currentEntitlements {
          guard case .verified(let transaction) = result else {
            continue
          }
          
          if transaction.revocationDate == nil {
            //          self.purchasedProductIDs.insert(transaction.productID)
          } else {
            //          self.purchasedProductIDs.remove(transaction.productID)
          }
        }
      } else {
        // Fallback on earlier versions
      }
    }
    
    
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
    }
    yearlyPay.backgroundColor = UIColor(named: "Theme")?.withAlphaComponent(0.3)
    yearlyPay.layer.borderColor = UIColor(named: "Theme")?.cgColor
    
    monthlyPay.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    monthlyPay.layer.borderColor = UIColor.lightGray.cgColor
    
    guard let path = Bundle.main.path(forResource: "paywall\(Int.random(in: 1...3))", ofType:"mp4") else {
      debugPrint("video.m4v not found")
      return
    }
    playerAV = AVPlayer(url: URL(fileURLWithPath: path))
    indicator.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let playerLayerAV = AVPlayerLayer(player: playerAV)
    
    playerParent.layer.addSublayer(playerLayerAV)
    playerLayerAV.videoGravity = .resizeAspectFill
    playerLayerAV.isOpaque = true

    playerLayerAV.opacity = 1
    loopVideo(videoPlayer: playerAV)
    playerLayerAV.frame = view.bounds
  }
  
  func loopVideo(videoPlayer: AVPlayer) {
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
        self.playerAV.seek(to: CMTime.zero)
        self.playerAV.play()
      }
  }

  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playerAV.play()
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
