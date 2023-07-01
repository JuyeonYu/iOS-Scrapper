//
//  CustomAlertViewController.swift
//  scrapper
//
//  Created by  유 주연 on 2023/07/02.
//  Copyright © 2023 johnny. All rights reserved.
//

import UIKit
import Lottie

protocol CustomAlertDelegate: AnyObject {
  func onOk()
}

class CustomAlertViewController: UIViewController {
  @IBOutlet weak var base: UIView!
  init?(coder: NSCoder, head: String, body: String) {
    self.headValue = head
    self.bodyValue = body
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  weak var delegate: CustomAlertDelegate?
  let headValue: String
  let bodyValue: String
  @IBOutlet weak var imageParent: UIView!
  @IBAction func onOk(_ sender: Any) {
    delegate?.onOk()
  }
  @IBOutlet weak var ok: UIButton!
  @IBOutlet weak var body: UILabel!
  @IBOutlet weak var head: UILabel!
  @IBAction func onClose(_ sender: Any) {
    dismiss(animated: true)
  }
  @IBOutlet weak var close: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    base.layer.cornerRadius = 32
    head.text = headValue
    body.text = bodyValue
    ok.layer.cornerRadius = 16
    let animationView: LottieAnimationView = .init(name: "18089-gold-coin")
    
    animationView.frame = imageParent.bounds
    imageParent.addSubview(animationView)
    animationView.loopMode = .loop
    animationView.play()
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
