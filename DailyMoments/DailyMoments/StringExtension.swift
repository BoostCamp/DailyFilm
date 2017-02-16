//
//  StringExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 14..
//  Copyright © 2017년 nam. All rights reserved.
//

import Foundation

extension String {
    
    func makeDocumentsDirectoryPath() -> String {
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = directoryPaths[0]
        return documentDirectoryPath.appending(self)
    }
    
    func makeFileURLWithDocumentsDirectoryPath(with documentsDirectoryPath: String) -> URL {
        
        let filePath = URL(fileURLWithPath: documentsDirectoryPath)
        return filePath.appendingPathComponent(self)
        
    }
    
    
    //dataFofmatter에 맞게 Date 타입으로 반환
    func convertStringToDate() -> Date? {
        print(self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
    
}
