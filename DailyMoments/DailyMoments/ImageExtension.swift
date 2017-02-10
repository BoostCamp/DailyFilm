//
//  ImageExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        
        let scale = UIScreen.main.scale
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width * scale
        let heightRatio = targetSize.height / self.size.height * scale
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            
        } else {
            
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        
        let rect =  CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        //  CGRect 만큼 draw
        self.draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func applyFilter(type filterName: String) -> UIImage{
       
        var resultImage:UIImage = self
        let scale = UIScreen.main.scale
        let originalOrientation: UIImageOrientation = self.imageOrientation
        
        guard let image = self.cgImage  else {
            fatalError("error..")
        }
        
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        
        let ciImage = CIImage(cgImage: image)
        
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {

            resultImage = UIImage(cgImage: context.createCGImage(output, from: output.extent)!, scale: scale, orientation: originalOrientation)
        }
        
        return resultImage
    }
}
