//
//  NewsTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import SnapKit
import Then

class NewsTableViewCell: UITableViewCell {
    let title = UILabel().then {
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 0
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 17)
    }
    let publishTime = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 11)
    }
    fileprivate func addSubViews() {
        [title, publishTime].forEach {
            contentView.addSubview($0)
        }
    }
    fileprivate func makeConstrants() {
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.trailing.equalToSuperview().inset(16)
        }
        publishTime.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.left.trailing.equalTo(title)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        makeConstrants()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
