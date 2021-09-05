//
//  KeywordTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import SnapKit
import Then

class KeywordTableViewCell: UITableViewCell {
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    let title = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .black
    }
    let exceptionKeyword = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .darkGray
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exceptionLabel: UILabel!
    @IBOutlet weak var exceptionBottom: NSLayoutConstraint!
    @IBOutlet weak var exceptionHeight: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func addSubViews() {
        contentView.addSubview(stackView)
        [title, exceptionKeyword].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    fileprivate func makeConstraints() {
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
