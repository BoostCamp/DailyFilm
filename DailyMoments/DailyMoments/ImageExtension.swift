//
//  ImageExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

extension UIImage {
    
    // target의 정한 사이즈 만큼 resize
    func resizeImage(targetSize: CGSize) -> UIImage {
        
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height 
        
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
    
     // image를 1:1 비율로 crop
     func cropToSquareImage() -> UIImage{
        
        var cropRect: CGRect?
        let imageWidth = self.size.width
        let imageHeight = self.size.height
     
        if imageWidth < imageHeight {
            // Potrait mode
            cropRect = CGRect(x: 0.0, y: (imageHeight - imageWidth) / 2.0, width: imageWidth, height: imageWidth)
        } else if imageWidth > imageHeight{
            // Landscape mode
            cropRect = CGRect(x: (imageWidth - imageHeight) / 2.0, y: 0.0, width: imageHeight, height: imageHeight)
        } else {
            return self
        }
        
        // Draw neew image in current graphics context

        guard let rect: CGRect = cropRect else {
            return UIImage()
        }
        
        return UIImage.init(cgImage: (self.cgImage?.cropping(to: rect))!)
    }
    
    // image에 fliter 적용하는 메소드
    func applyFilter(type filterName: String) -> UIImage{
       
        var resultImage:UIImage = self
        
        let originalOrientation: UIImageOrientation = self.imageOrientation
        
        
        
        guard let image = resultImage.cgImage  else {
            return self
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
                
/*
        scale : The scale factor to assume when interpreting the image data. Applying a scale factor of 1.0 results in an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor changes the size of the image as reported by the size property.
*/
                resultImage = UIImage(cgImage: context.createCGImage(output, from: output.extent)!, scale: 1, orientation: originalOrientation)
            }
            
        }
        
        return resultImage
    }
    
    // imageOrientation을 set
    func fixOrientationOfImage() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            
        default:
            context.draw(self.cgImage!, in: CGRect(origin: .zero, size: self.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    
}
