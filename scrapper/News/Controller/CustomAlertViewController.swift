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
  init?(
    coder: NSCoder,
    head: String?,
    body: String?,
    lottieImageName: String?,
    okTitle: String?,
    useOkDelegate: Bool
  ) {
    self.headValue = head
    self.bodyValue = body
    self.lottieImageName = lottieImageName
    self.okTitle = okTitle
    self.useOkDelegate = useOkDelegate
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  weak var delegate: CustomAlertDelegate?
  let headValue: String?
  let bodyValue: String?
  let lottieImageName: String?
  let okTitle: String?
  let useOkDelegate: Bool
  @IBOutlet weak var imageParent: UIView!
  @IBAction func onOk(_ sender: Any) {
    dismiss(animated: true) {
      guard self.useOkDelegate else { return }
      self.delegate?.onOk()
    }
  }
  @IBOutlet weak var ok: UIButton!
  @IBOutlet weak var body: UILabel!
  @IBOutlet weak var head: UILabel!
  @IBAction func onClose(_ sender: Any) {
    dismiss(animated: true)
  }
  @IBOutlet weak var close: UIButton!
  fileprivate func addLottieView() {
    if let lottieImageName {
      let animationView: LottieAnimationView = .init(name: lottieImageName)
      animationView.frame = imageParent.bounds
      imageParent.addSubview(animationView)
      animationView.loopMode = .loop
      animationView.play()
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    base.layer.cornerRadius = 16
    ok.layer.cornerRadius = 16
    addLottieView()
    
    if let headValue {
      head.text = headValue
    } else {
      head.removeFromSuperview()
    }
    
    if let bodyValue {
      body.text = bodyValue
    } else {
      body.removeFromSuperview()
    }
    
    if let okTitle {
      ok.setTitle(okTitle, for: .normal)
    } else {
      ok.removeFromSuperview()
    }
  }
}
