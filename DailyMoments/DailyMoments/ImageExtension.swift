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
        
        /*
         
         OpenGL ES는 하드웨어 가속 2D 및 3D 그래픽 렌더링을위한 C 기반 인터페이스를 제공합니다. iOS의 OpenGL ES 프레임 워크 (OpenGLES.framework)는 OpenGL ES 사양의 버전 1.1, 2.0 및 3.0 구현을 제공합니다.

         EAGL penGL ES 용 플랫폼 별 API
         the platform-specific APIs for OpenGL ES on iOS devices,
         
         */
        
        let openGLContext = EAGLContext(api: .openGLES3)
        
        let context = CIContext(eaglContext: openGLContext!)
        
        let ciImage = CIImage(cgImage: image)
        
        if let filter = CIFilter(name: filterName) {
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                
                resultImage = UIImage(cgImage: context.createCGImage(output, from: output.extent)!, scale: scale, orientation: originalOrientation)
            }
            
        }
        
        return resultImage
    }
}
