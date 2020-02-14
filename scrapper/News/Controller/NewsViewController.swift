//
//  NewsViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/13.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    var newsURLString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL (string:newsURLString!)
        let requestObj = URLRequest(url: url!)
        webview.load(requestObj)
    }
}
