//
//  News.swift
//  scrapper
//
//  Created by 주연  유 on 2020/02/11.
//  Copyright © 2020 johnny. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

var hostSet: Set<String> = []

class News: Codable {
  var title: String
  var itemDescription: String
  let urlString: String
  let publishTime: String
  let originalLink: String
  
  var publishTimestamp: TimeInterval? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // 네이버 api에서 넘어오는 시간 포멧
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    if let date = dateFormatter.date(from: publishTime) {
        return date.timeIntervalSince1970
    } else {
        return nil
    }
  }
  
  init(title: String, itemDescription: String, urlString: String, originalLink: String, publishTime: String) {
    // realm에 저장할때 '가 들어가면 filter로 값을 찾을 때 오류가 생김. '를 &squot; 바꿔 저장
    if title.contains("\'") {
      let temp1 = title.replacingOccurrences(of: "\'", with: "&squot;")
      self.title = temp1
    } else {
      self.title = title
    }
    self.originalLink = originalLink
    self.urlString = urlString
    self.publishTime = publishTime
      self.itemDescription = itemDescription
      
      if #available(iOS 16.0, *) {
          let result = hostSet.insert(URL(string: originalLink)?.host() ?? "none")
          if result.inserted {
              print("host: \(result.memberAfterInsert)")
          }
      } else {
          // Fallback on earlier versions
      }
      
      
  }
}

class BookMarkNewsRealm: Object {
  @objc dynamic var title: String = ""
  @objc dynamic var urlString: String = ""
  @objc dynamic var publishTime: String = ""
}

class ReadNewsRealm: Object {
  @objc dynamic var title: String = ""
}


let kPressDict: [String: String] = [
  "www.mbn.co.kr": "MBN",
    "weekly.donga.com" : "주간동아",
    "www.newsis.com" : "뉴시스",
    "www.jeonmae.co.kr" : "전국매일신문",
    "www.chosun.com" : "조선일보",
    "www.newspim.com" : "뉴스핌",
    "www.itooza.com" : "아이투자",
    "www.yeongnam.com" : "영남일보",
    "www.hankyung.com" : "한국경제",
    "news.bizwatch.co.kr" : "비즈워치",
    "www.etoday.co.kr" : "이투데이",
    "www.sedaily.com" : "서울경제",
    "www.jibs.co.kr": "JIBS제주방송",
    "www.hani.co.kr": "한겨레",
    "sjbnews.com": "새전북뉴스",
    "view.asiae.co.kr": "아시아경제",
    "www.ytn.co.kr": "YTN",
    "www.g-enews.com": "글로벌이코노믹",
    "www.womaneconomy.co.kr": "여성경제신문",
    "www.dt.co.kr": "디지털타임스",
    "news.mt.co.kr": "머니투데이",
    "www.mk.co.kr": "매일경제",
    "www.viva100.com": "브릿지경제",
    "www.edaily.co.kr": "이데일리",
    "www.fnnews.com": "파이낸셜뉴스",
    "science.ytn.co.kr": "YTN 사이언스",
    "www.newstomato.com": "뉴스토마토",
    "www.yna.co.kr": "연합뉴스",
    "news.einfomax.co.kr": "이포맥스",
    "biz.sbs.co.kr": "SBS Biz",
    "zdnet.co.kr": "ZDNet Korea",
    "www.news1.kr": "뉴스1",
    "www.etnews.com": "전자신문",
    "it.chosun.com": "IT조선",
    "www.imaeil.com": "매일신문",
    "www.bloter.net": "블로터",
    "news.kbs.co.kr": "KBS 뉴스",
    "www.wowtv.co.kr": "WOW TV",
    "www.khan.co.kr": "경향신문",
    "www.kmib.co.kr": "국민일보",
    "www.nocutnews.co.kr": "노컷뉴스",
    "daily.hankooki.com": "한국일보",
    "biz.heraldcorp.com": "헤럴드경제",
    "www.getnews.co.kr": "겟뉴스",
    "www.kfenews.co.kr": "KFE뉴스",
    "news.tvchosun.com": "TV조선",
    "www.businesspost.co.kr": "비즈니스포스트",
    "www.metroseoul.co.kr": "메트로서울",
    "www.yonhapnewstv.co.kr": "연합뉴스TV",
    "www.gukjenews.com": "국제뉴스",
    "biz.chosun.com": "조선비즈",
    "www.cstimes.com": "문화일보",
    "news.tf.co.kr": "TF경제",
    "www.sisaon.co.kr": "시사온",
    "www.wikitree.co.kr": "위키트리",
    "www.ibabynews.com": "아이베이비뉴스",
    "www.00news.co.kr": "공공뉴스",
    "www.jbnews.com": "전북일보",
    "www.beyondpost.co.kr": "비욘드포스트",
    "www.shinailbo.co.kr": "신아일보",
    "www.safetimes.co.kr": "세이프타임즈",
    "www.thereport.co.kr": "더리포트",
    "www.youthdaily.co.kr": "청년일보",
    "sports.donga.com": "동아스포츠",
    "www.inews24.com": "아이뉴스24",
    "magazine.hankyung.com": "한경매거진",
    "isplus.com": "일간스포츠",
    "www.press9.kr": "프레스9",
    "www.straightnews.co.kr": "스트레이트뉴스",
    "www.digitaltoday.co.kr": "디지털투데이",
    "www.autodaily.co.kr": "오토데일리",
    "economist.co.kr": "이코노미스트",
    "www.dailian.co.kr": "데일리안",
    "sports.khan.co.kr": "스포츠경향",
    "www.aitimes.com": "AI타임스",
    "www.heraldpop.com": "헤럴드팝",
    "biz.newdaily.co.kr": "뉴데일리",
    "kbench.com": "케이벤치",
    "www.pinpointnews.co.kr": "핀포인트뉴스",
    "www.newscj.com": "뉴스CJ",
    "www.segye.com": "세계일보",
    "www.moneys.co.kr": "머니S",
    "www.joseilbo.com": "조세일보",
    "www.asiatoday.co.kr": "아시아투데이",
    "www.smedaily.co.kr": "SM일간",
    "www.widedaily.com": "와이드데일리",
    "kr.aving.net": "AVING",
    "www.news2day.co.kr": "뉴스투데이",
    "news.sbs.co.kr": "SBS 뉴스",
    "www.yakup.com": "약업닷컴",
    "www.k-health.com": "케이헬스",
    "www.enewstoday.co.kr": "이뉴스투데이",
    "www.hellot.net": "헬로티",
    "byline.network": "바이라인 네트워크",
    "www.ekn.kr": "EKN",
    "www.livesnews.com": "라이브뉴스",
    "www.koreastocknews.com": "코리아스탁뉴스",
    "www.ebn.co.kr": "EBN",
    "www.betanews.net": "베타뉴스",
    "www.econonews.co.kr": "이코노뉴스",
    "www.seoulfn.com": "서울파이낸스",
    "www.ujeil.com": "우먼데일리",
    "www.globalepic.co.kr": "글로벌에픽",
    "www.sentv.co.kr": "세븐뉴스",
    "www.techm.kr": "Tech M",
    "www.biztribune.co.kr": "비즈트리뷴",
    "www.ddaily.co.kr": "디지털데일리",
    "www.pointdaily.co.kr": "포인트데일리",
    "www.newscape.co.kr": "뉴스케이프",
    "www.busan.com": "부산일보",
    "www.seoul.co.kr": "서울신문",
    "www.kukinews.com": "쿠키뉴스",
    "www.todaykorea.co.kr": "투데이코리아",
    "www.sisaweek.com": "시사위크",
    "www.newswatch.kr": "뉴스와치",
    "www.insight.co.kr": "인사이트",
    "www.bizwnews.com": "비즈더블유뉴스",
    "www.smarttoday.co.kr": "스마트투데이",
    "www.kpinews.kr": "KPINews",
    "www.socialvalue.kr": "소셜밸류",
    "www.choicenews.co.kr": "초이스뉴스",
    "www.ntoday.co.kr": "엔투데이",
    "www.joongdo.co.kr": "중도일보",
    "www.newsroad.co.kr": "뉴스로드",
    "www.naeil.com": "내일신문",
    "starin.edaily.co.kr": "스타인",
    "www.newsway.co.kr": "뉴스웨이",
    "www.ajunews.com": "아주뉴스",
    "gamefocus.co.kr": "게임포커스",
    "www.hansbiz.co.kr": "한스비즈",
    "www.dailysecu.com": "데일리시큐",
    "www.insidevina.com": "인사이드비나",
    "www.startuptoday.co.kr": "스타트업투데이",
    "www.datasom.co.kr": "데이터솜",
    "www.greened.kr": "그린드",
    "www.meconomynews.com": "미이코노미뉴스",
    "www.tfmedia.co.kr": "TF미디어",
    "www.thescoop.co.kr": "더스쿠프",
    "www.foodneconomy.com": "푸드이코노미",
    "www.delighti.co.kr": "딜라이트아이",
    "www.econovill.com": "이코노빌",
    "www.ceoscoredaily.com": "CEO스코어데일리",
    "www.jjn.co.kr": "전주일보",
    "kpenews.com": "KPENews",
    "www.consumernews.co.kr": "소비자뉴스",
    "news.dealsitetv.com": "딜사이트TV",
    "www.financialpost.co.kr": "파이낸셜포스트",
    "idsn.co.kr": "IDSN",
    "www.domin.co.kr": "도민일보",
    "www.fieldnews.kr": "필드뉴스",
    "www.newsen.com": "뉴스엔",
    "www.m-i.kr": "매일일보",
    "www.whitepaper.co.kr": "화이트페이퍼",
    "www.itbiznews.com": "IT비즈뉴스",
    "www.hankookilbo.com": "한국일보",
    "www.newsmaker.or.kr": "뉴스메이커",
    "www.techholic.co.kr": "테크홀릭",
    "www.nspna.com": "NSP통신",
    "www.fetv.co.kr": "FETV",
    "www.kdfnews.com": "한국면세뉴스",
    "www.hkbs.co.kr": "한국농어촌방송"
]
