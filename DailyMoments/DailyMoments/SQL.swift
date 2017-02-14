//
//  SQL.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 13..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation

struct CreateTableStatements {
    
    static let userProfile = "CREATE TABLE IF NOT EXISTS USER_PROFILE ( \n" +
        "user_index integer NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "user_id TEXT NOT NULL, \n" +
        "user_password TEXT NOT NULL, \n" +
        "user_nickname TEXT NOT NULL, \n" +
        "registerd_date timestamp DEFAULT CURRENT_TIMESTAMP \n" +
    ");\n"
    
    static let post = "CREATE TABLE IF NOT EXISTS POST ( \n" +
        "post_index integer NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
        "user_index integer NOT NULL, \n" +
        "content TEXT NOT NULL, \n" +
        "is_favorite integer, \n" +
        "created_date timestamp DEFAULT CURRENT_TIMESTAMP, \n" +
        "latitude REAL DEFAULT NULL, \n" +
        "longitude REAL DEFAULT NULL, \n" +
        "CONSTRAINT user_index FOREIGN KEY (user_index) REFERENCES USER_PROFILE (user_index) ON DELETE CASCADE ON UPDATE CASCADE \n" +
    ");\n"
    
}
