//
//  Constants.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation
import CoreGraphics

struct UserProfileConstants {
    static let id: String = "nso502354@gmail.com"
    static let password: String = "1234"
    static let nickname: String = "namsang"
}


enum SettingType: Int {
    case camera = 0
    case photo
    case location
}

struct DiaryPhotoTableViewConstants{
    
    static let showDiaryContentDetailViewControllerSegueIdentifier = "showDiaryContentDetailViewController"
    
    static let cellIdentifier: String = "DiaryPhotoCell"
    
    
}

enum DeviceInputType: Int {
    case back = 1
    case front
}

// 카메라 뷰에서 포토앨범, 카메라 모드인지 구분하기 위한 enum
enum AddPhotoMode {
    case photoLibrary
    case camera
}

struct ScreenType {
    static let width: [CGFloat] = [0.0, 1080.0, 720.0]
    
    enum Ratio: Int {
        case square = 0
        case retangle
        case full
        
    }
    
    static func numberOfRatioType() -> Int {
        return 3
    }
    
    static func photoWidthByDeviceInput(type deviceInput: Int) -> CGFloat {
        switch deviceInput {
        case DeviceInputType.back.rawValue:
            return ScreenType.width[deviceInput]
        case DeviceInputType.front.rawValue:
            return ScreenType.width[deviceInput]
        default:
            fatalError()
        }
    }
    
    static func photoHeightByAspectScreenRatio(_ deviceType: Int, ratioType: Int ) -> CGFloat {
        
        switch ratioType {
        case Ratio.square.rawValue:
            return ScreenType.width[deviceType]
        case Ratio.retangle.rawValue:
            return (ScreenType.width[deviceType] * 4) / 3
        case Ratio.full.rawValue:
            return (ScreenType.width[deviceType] * 16) / 9
        default:
            fatalError()
            
        }
    }
    
    static func getCGRectPreiewImageView(target rect : CGRect, yMargin: CGFloat, ratioType: Int) -> CGRect {
        
        switch ratioType {
        case Ratio.square.rawValue:
            return CGRect(x: 0, y: (yMargin * 2), width: rect.width, height: rect.width)
        case Ratio.retangle.rawValue:
            return CGRect(x: 0, y: 0, width: rect.width, height: (rect.width * 4) / 3)
        case Ratio.full.rawValue:
            return CGRect(x: 0, y: 0, width: rect.width, height: (rect.width * 16) / 9)
        default:
            fatalError()
        }
    }
    
    
}


let cameraFilterCollectionViewCellIdentifier: String = "FilterCell"

struct PhotoEditorTypes{
    
    static let titles: [String?] = ["Filter"]
    
    static let replacingOccurrencesWord : String = "CIPhotoEffect"
    static let filterNameLabelAnimationDelay: TimeInterval = TimeInterval(1)
    
    static let filterNameArray: [String] = ["CIPhotoEffectProcess", "CIPhotoEffectInstant", "Normal", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectTonal", "CIPhotoEffectFade", "CIPhotoEffectChrome", "CIPhotoEffectTransfer"].sorted(by: >)
    
    static func numberOfFilterType() -> Int {
        return filterNameArray.count
    }
    static func titleForIndexPath(_ indexPath: IndexPath) -> String {
        return filterNameArray[indexPath.row]
    }
    
    static func normalStatusFromFilterNameArray() -> String {
        return filterNameArray.first!
    }
    
    
}


let cellUnitValue: Float = 5

struct AlertContentConstant{
    static let titles: [String?] = ["카메라 사용 권한", "사진 앨범 사용 권한", "위치 정보 사용 권한"]
    static let messages: [String?] = ["설정 - DailyMoments에서 카메라 설정을 허가해주세요.", "설정 - DailyMoments에서 사진 설정을 허가해주세요.", "설정 - DailyMoments에서 위치 설정을 허가해주세요."]
    static let cancel: String = "취소"
    static let setting: String = "설정"
    
}


struct DatabaseConstant {
    static let databaseName:String = "/database.db"
}



struct Statement {
    
    struct CreateTable {
        static let userProfile = "CREATE TABLE IF NOT EXISTS USER_PROFILE ( \n" +
            "user_index integer NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "user_id TEXT NOT NULL, \n" +
            "user_password TEXT NOT NULL, \n" +
            "user_nickname TEXT NOT NULL, \n" +
            "created_date timestamp DEFAULT CURRENT_TIMESTAMP \n" +
        ");\n"
        
        static let post = "CREATE TABLE IF NOT EXISTS POST ( \n" +
            "post_index integer NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "user_index integer NOT NULL, \n" +
            "image_file_path TEXT NOT NULL, \n" +
            "content TEXT NOT NULL, \n" +
            "is_favorite integer, \n" +
            "created_date timestamp DEFAULT CURRENT_TIMESTAMP, \n" +
            "address TEXT DAFUALT NULL, \n" +
            "latitude FLOAT DEFAULT NULL, \n" +
            "longitude FLOAT DEFAULT NULL, \n" +
            "CONSTRAINT user_index FOREIGN KEY (user_index) REFERENCES USER_PROFILE (user_index) ON DELETE CASCADE ON UPDATE CASCADE \n" +
        ");\n"
        
    }
    
    struct Insert {
        
        static let userProfile = "INSERT INTO USER_PROFILE( \n" +
            "user_id, user_password, user_nickname, created_date) \n" +
        "values(?, ?, ?, ?);"
        
        static let post = "INSERT INTO POST( \n" +
            "user_index, image_file_path, content, is_favorite, created_date, address, latitude, longitude) \n" +
        "values(?, ?, ?, ?, ?, ?, ?, ?);"
        
    }
    
    struct Delete {
        static let post = "DELETE FROM POST WHERE post_index = ? and user_index = ?;"
    }
    
    struct Select {
        
        static let userProfile = "SELECT user_index, user_id, user_password, user_nickname, created_date FROM USER_PROFILE;"
        
        static let post = "SELECT post_index, user_index, image_file_path, content, is_favorite, created_date, address, latitude, longitude FROM POST WHERE user_index = ? order by post_index desc;"
        
        static let postById = "SELECT image_file_path, content, is_favorite, address, latitude, longitude FROM POST WHERE user_index = ? and created_date = ?;"
        
        static let userIndexOfUser = "SELECT user_index FROM USER_PROFILE WHERE user_id = ?;"
        
        static let postCountOfUser = "SELECT COUNT(*) as Count FROM POST WHERE user_index = ?;"
        
        static let duplicatedCheckOfUserProfile = "SELECT COUNT(*) as Count FROM USER_PROFILE WHERE user_id = ?;"
        
        static let nicknameOfUser = "SELECT user_nickname FROM USER_PROFILE WHERE user_index = ?;"
        
        static let imageFilePath = "SELECT image_file_path FROM POST WHERE post_index = ? and user_index = ?;"
    }
    
    struct Update {
        static let contentOfPost = "UPDATE POST SET content = ? WHERE post_index = ? and user_index = ?;"
    }
}

