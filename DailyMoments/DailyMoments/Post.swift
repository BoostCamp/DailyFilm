//
//  Post.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 14..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation

struct Post {
    
    var postIndex: Int32 // post index(autoincrement)
    var userIndex: Int32  // user index foreign key, reference USER_PROFILE TABLE
    var imageFilePath: String? // image file path
    var content: String?  // 사진에 추가할 텍스트 내용
    var isFavorite: Int32? // 위시리스트 추가 여부
    var createdDate: TimeInterval? // 사진 촬영 시간
    var address: String? // 변환된 현재 주소
    var latitude: Float? // 현재 좌표의 위도
    var longitude: Float? // 현재 좌표의 경도
    
    
    init(postIndex: Int32, userIndex: Int32, imageFilePath: String, content: String, isFavorite: Int32, createdDate: TimeInterval, address: String, latitude: Float, longitude: Float){
        
        self.imageFilePath = imageFilePath
        self.postIndex = postIndex
        self.userIndex = userIndex
        self.content = content
        self.isFavorite = isFavorite
        self.createdDate = createdDate
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
}
