//
//  UserProfile.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 14..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation

struct UserProfile {
    
    var userIndex: Int32 // post index(autoincrement)
    var userId: String?  // user Id(ex xxx@gamil.com
    var userPassword: String? // user password
    var userNickname: String? // user nickname (ex namsang)
    var createdDate: TimeInterval? // 촬영 시간
    
    
    init(userIndex: Int32, userId: String, userPassword: String, userNickname: String, createdDate: TimeInterval){
      
        self.userIndex = userIndex
        self.userId = userId
        self.userPassword = userPassword
        self.userNickname = userNickname
        self.createdDate = createdDate
        
    }

}
