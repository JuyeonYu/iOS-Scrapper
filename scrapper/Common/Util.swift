//
//  Util.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/14.
//  Copyright © 2020 johnny. All rights reserved.
//

import Foundation
import UIKit

class Util {
  static let sharedInstance = Util()
  
  init() {}
  
  
  // 뉴스 공유할 때 사용
  func shareBookmarks(_ news: [BookMarkNewsRealm]) {
    var newsSuite = (news.map { $0.title.htmlStripped + "\n" + $0.urlString  + "\n"})
    newsSuite.append(Constants.appDownloadURL)
    let objectsToShare = newsSuite as AnyObject
    showShareActivity(objectsToShare: objectsToShare)
  }
  func shareNews(_ news: News) {
    let newsSuite = [news.title.htmlStripped + "\n" + news.originalLink + "\n" + Constants.appDownloadURL] as AnyObject
    showShareActivity(objectsToShare: newsSuite)
  }
  private func showShareActivity(objectsToShare: AnyObject) {
    guard let topViewController = UIViewController.topViewController() else { return }
    let activityVC = UIActivityViewController(activityItems: objectsToShare as! [Any], applicationActivities: nil)
    activityVC.modalPresentationStyle = .popover
    activityVC.popoverPresentationController?.sourceView = topViewController.view
    topViewController.present(activityVC, animated: true, completion: nil)
  }
  private func showShareActivity(viewController: UIViewController, msg:String?, image:UIImage?, url: [String], sourceRect:CGRect?){
    var objectsToShare = [AnyObject]()
    
    objectsToShare = [url as AnyObject]
    
    if let image = image {
      objectsToShare = [image as AnyObject]
    }
    
    if let msg = msg {
      objectsToShare = [msg as AnyObject]
    }
    
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    activityVC.modalPresentationStyle = .popover
    activityVC.popoverPresentationController?.sourceView = viewController.view
    if let sourceRect = sourceRect {
      activityVC.popoverPresentationController?.sourceRect = sourceRect
    }
    
    viewController.present(activityVC, animated: true, completion: nil)
  }
  
  func naverTimeFormatToNormal(date: String) -> String {
    let naverDateFormatter = DateFormatter()
    
    // 시간 포멧 변경 세팅
    naverDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // 네이버 api에서 넘어오는 시간 포멧
    naverDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let startTime = naverDateFormatter.date(from: date) else {return "?"}
    naverDateFormatter.dateFormat = "yyyy-MM-dd hh:mm a" // 내가 뿌리고 싶은 시간 포멧
    return naverDateFormatter.string(from: startTime)
  }
  
  func showToast(controller: UIViewController, message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.view.alpha = 0.6
    alert.view.layer.cornerRadius = 30
    
    controller.present(alert, animated: true, completion: nil)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      alert.dismiss(animated: true, completion: nil)
    }
  }
}

public extension String {
  var htmlStripped: String {
    do {
      guard let data = self.data(using: .unicode) else {
        return ""
      }
      let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
      return attributed.string
    } catch {
      return ""
    }
  }
}

public extension UITableView {
  func setEmptyMessage(_ message: String) {
    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
    messageLabel.text = message
    messageLabel.textColor = .black
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center
    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
    messageLabel.sizeToFit()
    
    self.backgroundView = messageLabel
    self.separatorStyle = .none
  }
  
  func restore() {
    self.backgroundView = nil
    self.separatorStyle = .singleLine
  }
}

extension UIViewController {
  func present(alert: UIAlertController) {
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let popoverController = alert.popoverPresentationController {
        popoverController.sourceView = self.view
        popoverController.sourceRect = CGRect(
          x: self.view.bounds.midX,
          y: self.view.bounds.midY,
          width: 0,
          height: 0)
        popoverController.permittedArrowDirections = []
        self.present(alert, animated: true, completion: nil)
      } else {
        self.present(alert, animated: true, completion: nil)
      }
    } else {
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}
