//
//  NewsViewController.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/13.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var webview: WKWebView!
    var newsURLString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.uiDelegate = self
        webview.navigationDelegate = self
        
        let test = "http://www.naver.com"
        let testURL = URL(string: test)!
        let urlRequest = URLRequest(url: testURL)
        webview.load(urlRequest)
//        if let encoded = newsURLString!.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),let myURL = URL(string: encoded){
//            print(myURL)
//            let urlRequest = URLRequest(url: myURL)
//            wkWebview.load(urlRequest)
//        }


        
    }
}
