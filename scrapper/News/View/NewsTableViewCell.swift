//
//  NewsTableViewCell.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var press: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var unread: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var publishTime: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var isSelectMode: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard isSelectMode else {
            return
        }
        
        if selected {
            selectImage.image = UIImage(systemName: "circle.inset.filled")?.withRenderingMode(.alwaysTemplate)
            selectImage.tintColor = UIColor(named: "Theme")!
        } else {
            selectImage.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
            selectImage.tintColor = UIColor(named: "Theme")!
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectImage.isHidden = true
        unread.layer.masksToBounds = true
        
        title.text = nil
        desc.text = nil
        press.text = nil
        publishTime.text = nil
        
        desc.textColor = .lightGray
        publishTime.textColor = .lightGray
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        unread.layer.cornerRadius = unread.frame.width / 2
    }
    
    func configure(news: News, isNew: Bool) {
        self.title.text = news.title
            .replacingOccurrences(of: "&squot;", with: "\'")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        self.desc.text = news.itemDescription.htmlStripped
        
        if let publishTimestamp = news.publishTimestamp, let date = Date(timeIntervalSince1970: publishTimestamp) as Date? {
            let formatedDate = date.timeAgo
            publishTime.isHidden = false
            publishTime.text = formatedDate
        } else {
            publishTime.isHidden = true
        }
        
        self.unread.superview?.isHidden = !isNew
        
        if #available(iOS 16.0, *) {
            if let host = URL(string: news.originalLink)?.host() {
                self.press.text = kPressDict[host] ?? host
                    .replacingOccurrences(of: "www.", with: "")
                    .replacingOccurrences(of: ".co.kr", with: "")
                    .replacingOccurrences(of: ".com", with: "")
                    .replacingOccurrences(of: ".", with: " ")
            }
        } else {
            self.press.text = news.originalLink
        }
    }
    
    func configure(group: GroupRealm) {
        isSelectMode = true
        selectImage.isHidden = false
        if group.name.isEmpty {
            title.text = "기본"
        } else {
            title.text = group.name
        }
        
        publishTime.isHidden = true
        unread.isHidden = true
    }
}
