//
//  RootViewController.swift
//  scrapper
//
//  Created by Juyeon on 2020/07/22.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let viewController: UIViewController?
        
        if UserDefaultsManager.getLogin() {
            viewController = self.storyboard?.instantiateViewController(identifier: "mainViewController")
        } else {
            viewController = self.storyboard?.instantiateViewController(identifier: "loginViewController")
        }
        
        viewController?.modalPresentationStyle = .fullScreen
        self.present(viewController!, animated: false, completion: saveLogin)
    }
    
    func saveLogin() {
        UserDefaultsManager.setLogin(login: true)
    }
}
