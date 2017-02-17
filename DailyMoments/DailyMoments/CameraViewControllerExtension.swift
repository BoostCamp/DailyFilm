//
//  CameraViewControllerExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 10..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController {
    
    enum FlashModeConstant: Int {
        case off = 0
        case on
        case auto
    }
    
    
    // MARK:- Flash Mode
    
    func getCurrentFlashMode(_ mode : Int) -> AVCaptureFlashMode{
        
        var valueOfAVCaptureFlashMode: AVCaptureFlashMode = .off
        
        switch mode {
        case FlashModeConstant.off.rawValue:
            valueOfAVCaptureFlashMode = .off
        case FlashModeConstant.auto.rawValue:
            valueOfAVCaptureFlashMode = .auto
        case FlashModeConstant.on.rawValue:
            valueOfAVCaptureFlashMode = .on
        default:
            break;
        }
        return valueOfAVCaptureFlashMode
    }
    
    // MARK:- Change the device’s activeFormat property.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("end")
    }
    
    // 초점 맞추기
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        
        if let coordinates = touches.first, let device = captureDevice {
            
            
            print("x: \( coordinates.location(in: cameraView).x), y: \(coordinates.location(in: cameraView).y)")
            print("cameraView height: \(cameraView.bounds.height)")
            var point = CGPoint.zero
            point.y = coordinates.location(in: cameraView).y / cameraView.bounds.height
            
            print("cameraView touch y ratio: \( 1 - point.y / 5)")
            
            
            
            // 전면 카메라는 FocusPointOfInterest를 지원하지 않습니다.
            if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(AVCaptureFocusMode.autoFocus) {
                let focusPoint = touchPercent(touch : coordinates)
                dump(focusPoint)
                do {
                    try device.lockForConfiguration()
                    
                    // FocusPointOfInterest 를 통해 초점을 잡아줌.
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                    
                    if focusBox != nil {
                        // 초점 박스가 있으면 위치를 바꿔줌
                        changeFocusBoxCenter(for: coordinates.location(in: cameraView))
                    } else {
                        // 초점 박스가 없으면 그려줌
                        makeRectangle(at : coordinates)
                    }
                    
                    
                    cameraView.addSubview(self.focusBox)
                } catch{
                    fatalError()
                }
            }
            // 전면 카메라에서는 FocusPointOfInterest 를 지원하지 않는다.
        }

        
        
        
        /* 
         if let coordinates = touches.first, let device = captureDevice {
      
            
      
                let focusPoint = touchPercent(touch : coordinates)
                
                do {
                    try device.lockForConfiguration()
                    //focus 잡은 point로 set
                    device.setFocusModeLockedWithLensPosition(AVCaptureLensPositionCurrent, completionHandler: { (time) in
//                        print("setFocusModeLockedWithLensPosition:", time)
                    })
                    let minISO = device.activeFormat.minISO
                    let maxISO = device.activeFormat.maxISO
                    let clampedISO = Float(focusPoint.y) * (maxISO - minISO) + minISO
//                        print(focusPoint.y)
                    
                    //                    print("minISO: \(minISO)")
//                    print("maxISO: \(maxISO)")
//                    print("clampedISO: \(clampedISO)")

                    device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: clampedISO, completionHandler: { (time) in
//                        print("setExposureModeCustomWithDuration:", time)
                    })
                    device.unlockForConfiguration()
                    
                    if focusBox != nil {
                        self.focusBox.removeFromSuperview()
                    }
                    makeRectangle(at : coordinates)
                    cameraView.addSubview(self.focusBox)
                } catch{
                    fatalError()
                }
 
        }*/

    }
    
    // 초점 박스를 이동하는 메소드
    func changeFocusBoxCenter(for location: CGPoint )
    {
        self.focusBox.center.x = location.x
        self.focusBox.center.y = location.y
    }
    
    func touchPercent(touch coordinates: UITouch) -> CGPoint {
        
        // 0~1.0 으로 x, y 화면대비 비율 구하기
        let x = coordinates.location(in: cameraView).y / cameraView.bounds.height
        let y = 1.0 - coordinates.location(in: cameraView).x / cameraView.bounds.width
        let ratioOfPoint = CGPoint(x: x, y: y)
        
        return ratioOfPoint
    }
    
    
    func makeRectangle(at coordinates : UITouch) {
        
        // 화면 사이즈 구하기
        let screenBounds = cameraView.bounds
        
        // 화면 비율에 맞게 정사각형의 focus box 그리기
        var rectangleBounds = screenBounds
        rectangleBounds.size.width = screenBounds.size.width / 5
        rectangleBounds.size.height = screenBounds.size.width / 5
        
        // 터치된 좌표에 focusBox의 높이, 너비의 절반 값을 빼주어서 터치한 좌표를 중심으로 그려지게 설정
        rectangleBounds.origin.x = coordinates.location(in: cameraView).x - (rectangleBounds.size.width / 2)
        rectangleBounds.origin.y = coordinates.location(in: cameraView).y - (rectangleBounds.size.height / 2)
        
        self.focusBox = UIView(frame: rectangleBounds)
        self.focusBox.layer.borderColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 0.5).cgColor
        self.focusBox.layer.borderWidth = 0.5
        
    }
}
