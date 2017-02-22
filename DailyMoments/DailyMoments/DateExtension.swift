//
//  DateExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 13..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation

extension Date {
    
    //dateFormatter에 맞게 String 타입으로 반환
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 H:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일 H시"
        return dateFormatter.string(from: self)
    }
    
    func makeName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return "/IMG_" + dateFormatter.string(from: self)
    }
    
    
    // 현재 시간을 DateComponents 형식으로 반환
    func getDateComponents() -> Date {
        
        var now:Date = self
        var calendar = Calendar.current
        let timezone = NSTimeZone.system
        calendar.timeZone = timezone
        
        //timezone을 사용해서 date의 components를 지정해서 가져옴.
        let anchorComponets = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: now)
        
        let getDateFromDateComponents = calendar.date(from: anchorComponets)
        if let currentDate = getDateFromDateComponents {
            now = currentDate
        }
        return self
    }
    
}
