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
}
