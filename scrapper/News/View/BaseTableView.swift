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
    case noData
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
            case .noData:
                lottieParentView.isHidden = false
                loadingView.isHidden = true
                noDataView.isHidden = false
            case .hasData:
                lottieParentView.isHidden = true
            }
        }
    }
    private let lottieParentView: UIView = UIView()
    private let loadingView: LottieAnimationView = LottieAnimationView(type: .loading)
    private let noDataView: LottieAnimationView = LottieAnimationView(type: .noData)

    private func config() {
        loadingView.loopMode = .loop
        loadingView.play()
        noDataView.play()
        noDataView.loopMode = .loop
        
        lottieParentView.backgroundColor = .red
        addSubview(lottieParentView)
        
        lottieParentView.addSubview(noDataView)
        lottieParentView.addSubview(loadingView)
        
        lottieParentView.frame = bounds

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
         noDataView.centerYAnchor.constraint(equalTo: lottieParentView.centerYAnchor),
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
