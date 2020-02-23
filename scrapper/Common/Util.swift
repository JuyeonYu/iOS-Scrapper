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
    func showShareActivity(viewController: UIViewController, msg:String?, image:UIImage?, url:String?, sourceRect:CGRect?){
        var objectsToShare = [AnyObject]()

        if let url = url {
            objectsToShare = [url as AnyObject]
        }

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
        let dateFormatter = DateFormatter()
        
        // 시간 포멧 변경 세팅
        naverDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z" // 네이버 api에서 넘어오는 시간 포멧
        let beforeDate = naverDateFormatter.date(from: date)!
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a" // 내가 뿌리고 싶은 시간 포멧
        return dateFormatter.string(from: beforeDate)
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
    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }
}
