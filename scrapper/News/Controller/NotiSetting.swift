//
//  NotiSetting.swift
//  scrapper
//
//  Created by  유 주연 on 7/6/24.
//  Copyright © 2024 johnny. All rights reserved.
//

import SwiftUI

struct NotiSetting: View {
  @State private var time: Date = Date()
  @State private var showingPeriod: Bool = false
  @State private var showingTime: Bool = false
  var body: some View {
    VStack {
      Text("내가 등록한 키워드의").font(.title)
      Text("새로운 뉴스가 생기면").bold().font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
      if #available(iOS 15.0, *) {
        Text("키워드 별로 설정할 수 있어요").font(.callout).foregroundStyle(.gray)
          .padding(.top)
      } else {
        // Fallback on earlier versions
      }
      
      Spacer()
      if #available(iOS 15.0, *) {
        Button("일정 시간마다 알려 주세요") {
          showingPeriod = true
        }
        .foregroundColor(Color(UIColor.label))
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.lightGray.withAlphaComponent(0.5)))
        .clipShape(.capsule)
        .padding(.horizontal)
        .confirmationDialog("얼마 간격으로 알려드릴까요?", isPresented: $showingPeriod, titleVisibility: .visible) {
          Button("15분") {
            
          }
          Button("30분") {
            
          }
          Button("매 시간") {
            
          }
        }
      } else {
        // Fallback on earlier versions
      }
      
      Button("내가 정한 시간에 알려주세요") {
        showingTime = true
      }
      .foregroundColor(Color(UIColor.label))
      .frame(height: 60)
      .frame(maxWidth: .infinity)
      .background(Color(UIColor.lightGray.withAlphaComponent(0.5)))
      .clipShape(.capsule)
      .padding(.horizontal)
      .sheet(isPresented: $showingTime, content: {
        Form {
          DatePicker(selection: $time, displayedComponents: .hourAndMinute) {
            Text("test")
          }
        }
        
      })
      Button("알림 받지 않기") {
        
      }
      .foregroundColor(Color(UIColor.label))
      .frame(height: 60)
      .frame(maxWidth: .infinity)
      .background(Color(UIColor.lightGray.withAlphaComponent(0.5)))
      .clipShape(.capsule)
      .padding(.horizontal)
    }
    .padding(.top, 50)
  }
}

#Preview {
  NotiSetting()
}


