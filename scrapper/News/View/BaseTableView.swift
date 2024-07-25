//
//  BaseTableView.swift
//  scrapper
//
//  Created by  유 주연 on 7/24/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import UIKit
import Lottie

enum DataFetchStatus {
    case loading
    case noData(message: String?)
    case hasData
}

class BaseTableView: UITableView {
    var dataFetchStatus: DataFetchStatus = .loading {
        didSet {
            switch dataFetchStatus {
            case .loading:
                lottieParentView.isHidden = false
                loadingView.isHidden = false
                noDataView.isHidden = true
                messageLabel.isHidden = true
            case .noData(let message):
                lottieParentView.isHidden = false
                loadingView.isHidden = true
                noDataView.isHidden = false
                messageLabel.text = message
                messageLabel.isHidden = false
            case .hasData:
                lottieParentView.isHidden = true
                messageLabel.isHidden = true
            }
        }
    }
    private let lottieParentView: UIView = UIView()
    private let messageLabel: UILabel = UILabel()
    private let loadingView: LottieAnimationView = LottieAnimationView(type: .loading)
    private let noDataView: LottieAnimationView = LottieAnimationView(type: .noData)

    private func config() {
        loadingView.loopMode = .loop
        loadingView.play()
        noDataView.play()
        noDataView.loopMode = .loop
        
        addSubview(lottieParentView)
        addSubview(messageLabel)
        
        lottieParentView.addSubview(noDataView)
        lottieParentView.addSubview(loadingView)
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        lottieParentView.frame = bounds
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        [messageLabel.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor),
         messageLabel.bottomAnchor.constraint(equalTo: noDataView.topAnchor, constant: -16)].forEach {
            $0.isActive = true
        }

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        [loadingView.centerXAnchor.constraint(equalTo: lottieParentView.centerXAnchor),
         loadingView.centerYAnchor.constraint(equalTo: lottieParentView.centerYAnchor),
         loadingView.widthAnchor.constraint(equalToConstant: 70),
         loadingView.heightAnchor.constraint(equalToConstant: 70)
        ].forEach {
            $0.isActive = true
        }
        
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        [noDataView.centerXAnchor.constraint(equalTo: lottieParentView.centerXAnchor),
         noDataView.centerYAnchor.constraint(equalTo: lottieParentView.centerYAnchor, constant: 10),
         noDataView.widthAnchor.constraint(equalToConstant: 300),
         noDataView.heightAnchor.constraint(equalToConstant: 300)
        ].forEach {
            $0.isActive = true
        }
        dataFetchStatus = .loading
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
}
