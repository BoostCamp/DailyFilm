//
//  DiaryHomeViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

class DiaryHomeViewController: UIViewController {

    var authorizationStatus: PHAuthorizationStatus? // // Photo 접근 권한을 위한 저장 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let fileManager = FileManager.default
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory: String = directoryPaths[0]
        let databasePath: String = documentDirectory.appending("/database.db")
        
        if fileManager.fileExists(atPath: databasePath as String) == false {
            let database = FMDatabase(path: databasePath as String)
            if database == nil{
                print("DB 생성 오류")
            }

            if((database?.open()) != nil) {
                
                if !(database?.executeStatements(CreateTableStatements.userProfile))! {
                    print("USER_PROFILE CREATE TABLE ERROR")
                }
                
                if !(database?.executeStatements(CreateTableStatements.post))!{
                    print("POST CREATE TABLE ERROR")
                }
                
                database?.close()
                
            } else {
                print("DB 연결 오류")
            }
        }
    }

    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryHomeViewController")
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                print(authorizationStatusOfPhoto)
            case .denied:
                print(authorizationStatusOfPhoto)
            case .notDetermined:
                print(authorizationStatusOfPhoto)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print(authorizationStatusOfPhoto)
            }
        }

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in DiaryHomeViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in DiaryHomeViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in DiaryHomeViewController")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
