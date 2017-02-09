//
//  Constants.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation


enum SettingType: Int {
    case Camera = 0
    case Photo
}
struct AlertContentConstant{
    static let titles: [String?] = ["카레라 사용 권한", "사진 앨범 사용 권한"]
    static let messages: [String?] = ["설정 - DailyMoments에서 카메라 설정을 허가해주세요.", "설정 - DailyMoments에서 사진 설정을 허가해주세요."]
    static let cancel: String = "취소"
    static let setting: String = "설정"
    
}
