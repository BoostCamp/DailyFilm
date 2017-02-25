//
//  UIColorExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 13..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

extension UIColor {
    static func easyColor(red: Float, green: Float, blue: Float, alpha: Float = 1.0) -> UIColor {
        
        return UIColor(colorLiteralRed: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    static func appleBlue() -> UIColor {
        return UIColor.init(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    }
}
