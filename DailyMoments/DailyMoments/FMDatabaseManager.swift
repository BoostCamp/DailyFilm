//
//  FMDatabaseManager.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 14..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class FMDatabaseManager: NSObject {
    
    // singleton patterns
    private static let manager : FMDatabaseManager = FMDatabaseManager()
    
    var fmdb:FMDatabase?
    
    // get singleton instance
    class func shareManager() -> FMDatabaseManager {
        return manager
    }
    
    func openDatabase(databaseName : String)  {
        
        let fileManager = FileManager.default
        
        // document directory 에 database filepath 생성
        let databasePath = DatabaseConstant.databaseName.makeDocumentsDirectoryPath()
        
        // 존재하면 true, 아니면 false
        if fileManager.fileExists(atPath: databasePath as String) == false {
            
            fmdb = FMDatabase(path: databasePath as String)
            
            if fmdb == nil {
                print("FMDB is nil")
                dump(fmdb?.lastErrorMessage())
                return
            }
            
            if((fmdb?.open()) != nil) {
                createTable()
                
            } else {
                print("CREATE - DATABASE OPEN ERROR ")
                dump(fmdb?.lastErrorMessage())
                return
            }
        }
    }
    
    func createTable(){
        
        if !(fmdb?.executeStatements(Statement.CreateTable.userProfile))! {
            print("USER_PROFILE CREATE TABLE ERROR")
            dump(fmdb?.lastErrorMessage())
        }
        
        let resultOfUserProfileCreateTable = fmdb?.executeStatements(Statement.CreateTable.userProfile)
        let resultOfPostCreatetable = fmdb?.executeStatements(Statement.CreateTable.post)
        
        dump(resultOfUserProfileCreateTable)
        dump(resultOfPostCreatetable)
        
        
        
        fmdb?.close()
    }
    
    func insert(query statement: String, valuesOfColumns: [Any] ) -> Bool {
        
        let fileManager = FileManager.default
        
        // document directory 에 database filepath 생성
        let databasePath = DatabaseConstant.databaseName.makeDocumentsDirectoryPath()
        
        if fileManager.fileExists(atPath: databasePath as String)  {
            
            fmdb = FMDatabase(path: databasePath as String)
            
            if fmdb == nil {
                dump(fmdb?.lastErrorMessage())
                return false
            }
            
            if((fmdb?.open()) != nil) {
                
                if let result = fmdb?.executeUpdate(statement, withArgumentsIn: valuesOfColumns) {
                    fmdb?.close()
                    return result
                }
            
            } else {
                print("DATABASE OPEN ERROR")
                dump(fmdb?.lastErrorMessage())
                
                return false
            }
        }
        return false
    }
    
    func selectUserProfile(query statement: String, value userId: String...) -> [UserProfile]{
        
        
        var userProfiles: [UserProfile] = []
        
        let fileManager = FileManager.default
        
        // document directory 에 database filepath 생성
        let databasePath = DatabaseConstant.databaseName.makeDocumentsDirectoryPath()
        
        if fileManager.fileExists(atPath: databasePath as String) {
            
            fmdb = FMDatabase(path: databasePath as String)
            
            if fmdb == nil {
                dump(fmdb?.lastErrorMessage())
                
            }
            
            if((fmdb?.open()) != nil) {
                
                let results:FMResultSet? =  fmdb?.executeQuery(statement, withArgumentsIn: userId)
                
                if results != nil {
                    
                    if (results?.next())! {
                        let userIndex: Int32 = (results?.int(forColumn: "user_index"))!
                        let userId: String = (results?.string(forColumn: "user_id"))!
                        let userNickname: String = (results?.string(forColumn: "user_nickname"))!
                        let userPassword: String = (results?.string(forColumn: "user_password"))!
                        let createdDate: Double = (results?.double(forColumn: "created_date"))!

                        let userProfile: UserProfile = UserProfile(userIndex: userIndex, userId: userId, userPassword: userPassword, userNickname: userNickname, createdDate: createdDate)

                        userProfiles.append(userProfile)

                    }
                    fmdb?.close()
                }
                
            } else {
                print("DATABASE OPEN ERROR")
                dump(fmdb?.lastErrorMessage())
                
            }
        }
        return userProfiles
    }
    
    
    func selectPosts(query statement: String, value userIndex: Int32...) -> [Post]{
        
        var posts: [Post] = []
        
        let fileManager = FileManager.default
        
        // document directory 에 database filepath 생성
        let databasePath = DatabaseConstant.databaseName.makeDocumentsDirectoryPath()
        
        if fileManager.fileExists(atPath: databasePath as String) {
            
            fmdb = FMDatabase(path: databasePath as String)
            
            if fmdb == nil {
                dump(fmdb?.lastErrorMessage())
                
            }
            
            if((fmdb?.open()) != nil) {
                
                let results:FMResultSet? =  fmdb?.executeQuery(statement, withArgumentsIn: userIndex)
                
                if results != nil {
                    
                    while (results?.next())! {
                        let postIndex: Int32 = (results?.int(forColumn: "post_index"))!
                        let userIndex: Int32 = (results?.int(forColumn: "user_index"))!
                        let imageFilePath: String = (results?.string(forColumn: "image_file_path"))!
                        let content: String = (results?.string(forColumn: "content"))!
                        let isFavorite: Int32 = (results?.int(forColumn: "is_favorite"))!
                        let createdDate: Double = (results?.double(forColumn: "created_date"))!
                        let latitude = (results?.double(forColumn: "latitude"))!
                        let longitude = (results?.double(forColumn: "longitude"))!
                        
                        let post: Post = Post(postIndex: postIndex, userIndex: userIndex, imageFilePath: imageFilePath, content: content, isFavorite: isFavorite, createdDate: createdDate, latitude: Float(latitude), longitude: Float(longitude))
                        
                        posts.append(post)
                        
                    }
                    fmdb?.close()
                }
                
            } else {
                print("DATABASE OPEN ERROR")
                dump(fmdb?.lastErrorMessage())
                
            }
        }
        return posts
    }
}

