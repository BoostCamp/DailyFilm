//
//  CameraViewControllerExtension.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 10..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreImage


extension CameraViewController {
    
    static let showEditPhotoViewControllerSegueIdentifier = "showEditPhotoViewControllerSegue"
    
    static let showPhotoAlbumCollectionViewSegueIdentifier = "showPhotoAlbumCollectionViewControllerSegue"
    
    enum FlashModeConstant: Int {
        case off = 0
        case on
        case auto
    }
    
    // camera 관련
    struct CameraRelatedCoreImageResource{
        var pixelBuffer: CVImageBuffer? = nil
        var ciImage: CIImage? = nil
        var cgImage: CGImage? = nil
        
    }
    
    // face recognition 관련 
    struct FaceDetectRelatedResource {
        var faceDetector: CIDetector? = nil
        var feature: [CIFeature]? = nil
        var accuracy: [String : Any]? = nil
        
    }
    
    
    // MARK:- Setup and configure UI
    
    
    func disableCameraOptionButton(){
        
        switchOfCameraBarButtonItem.isEnabled = false
        flashOfCameraBarButtonItem.isEnabled = false
    }
    
    // 포토 앨범을 통해서 사진을 선택할 때 기존 UI를 가려주는 메소드
    func changeUIWhenPickImageFromPhotoAblum(){

        flashOfCameraBarButtonItem.image = UIImage(named: "photo_edit")
        
        screenRatioBarButtonItem.tintColor = UIColor.clear
        photoAlbumBarButton.tintColor = UIColor.clear
        shutterOfCameraBarButtonItem.tintColor = UIColor.clear
        switchOfCameraBarButtonItem.tintColor = UIColor.clear
        
        screenRatioBarButtonItem.isEnabled = false
        photoAlbumBarButton.isEnabled = false
        shutterOfCameraBarButtonItem.isEnabled = false
        switchOfCameraBarButtonItem.isEnabled = false

    }
    
    func setUpCamera(){
        
        // 포토 라이브러리에서 이미지를 가져온 경우 return
        if photoMode == AddPhotoMode.photoLibrary {
            
            changeUIWhenPickImageFromPhotoAblum()
            
            return
        }
        
        switchOfCameraBarButtonItem.isEnabled = true
        flashOfCameraBarButtonItem.isEnabled = true
        
        
        /*
         
         iOS 10.0+
         
         AVCaptureDeviceDiscoverySession(deviceTypes:mediaType:position)
         → Creates a discovery session for finding devices with the specified criteria.
         
         A query for finding and monitoring available capture devices.
         
         Overview
         
         Use this class to find all available capture devices matching a specific device type (such as microphone or wide-angle camera), supported media types for capture (such as audio, video, or both), and position (front- or back-facing).
         
         After creating a device discovery session, you can inspect its devices array to choose a device for capture, or observe that property to be notified when devices become available or unavailable.
         
         */
        
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        if let session = captureSession {
            for discoveredDevice in (deviceSession?.devices)! {
                
                // cameraPosition: 카메라가 back, front인지를 저장하는 프로퍼티
                if discoveredDevice.position == cameraPosition {
                    captureDevice = discoveredDevice // Device를 Set
                    
                    if cameraPosition == .back {
                        session.sessionPreset = AVCaptureSessionPreset1920x1080
                    } else if cameraPosition == .front {
                        session.sessionPreset = AVCaptureSessionPreset1280x720
                    }
                    
                    do {
                        let input = try AVCaptureDeviceInput(device: discoveredDevice)
                        
                        if session.canAddInput(input){
                            session.addInput(input)
                            
                            if session.canAddOutput(photoOutput), session.canAddOutput(videoDataOutput){
                                
                                session.addOutput(photoOutput)
                                
                                guard let videoOutput = videoDataOutput else {
                                    print("video output error")
                                    return
                                }
                                
                                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                                session.addOutput(videoOutput)
                                
                                session.startRunning()
                                
                            }
                            
                        }
                    } catch let avCaptureError {
                        print(avCaptureError)
                    }
                }
            } // End of find device
        }
        
    }
    

    
    // MARK:- DidoutPutSampleBuffer and didFinishProcessingPhotoSampleBuffer
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // 전면 카메라일 때 좌우반전 되지 않게 변경 (video Mirror disabled)
        if cameraPosition == .front {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        connection.videoOrientation = .portrait
        
        cameraRelatedCoreImageResource?.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        cameraRelatedCoreImageResource?.ciImage = CIImage(cvPixelBuffer: (cameraRelatedCoreImageResource?.pixelBuffer)!)
        
        
        guard let context = context else {
            print("context guard error")
            return
        }
        
        guard let cameraViewPhotoSize = cameraViewPhotoSize else {
            print("cameraViewPhotoSize guard error")
            
            return
        }
        cameraRelatedCoreImageResource?.cgImage = context.createCGImage((cameraRelatedCoreImageResource?.ciImage)!, from: CGRect(x: 0.0, y: 0.0, width: cameraViewPhotoSize.width, height: cameraViewPhotoSize.height))!
        
        
        originalPhotoImage = UIImage(cgImage: (cameraRelatedCoreImageResource?.cgImage)!)
        
        if let filterName = filterName {
            
            if filterName == PhotoEditorTypes.normalStatusFromFilterNameArray(){
                DispatchQueue.main.async {
                    self.previewImageView.image = self.originalPhotoImage
                  
                    if self.cameraPosition == .front, self.isAddFunEmoticon == true {
                        self.faceDetectRelatedResource?.feature = self.faceDetectRelatedResource?.faceDetector?.features(in: (self.cameraRelatedCoreImageResource?.ciImage)!, options: self.imageOptions)
                        
                        for face in self.faceDetectRelatedResource?.feature as! [CIFaceFeature] {
                            
                            self.funFaceIcon?.frame = CGRect(x: (face.mouthPosition.x - (self.previewImageView.bounds.width / 2)) - (face.bounds.size.width / 2), y: ((self.previewImageView.bounds.height) - face.mouthPosition.y - (face.bounds.size.height / 3)), width: face.bounds.size.width, height: face.bounds.size.height)
                            
                        }

                    }
                    
                    
                }
                
            } else {
                if let filter = CIFilter(name: filterName) {
                    filter.setDefaults()
                    
                    filter.setValue(cameraRelatedCoreImageResource?.ciImage, forKey: kCIInputImageKey)
                    if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                        
                        DispatchQueue.main.async {
                            
                            self.previewImageView.image = UIImage(cgImage: context.createCGImage(output, from: CGRect(x: 0, y: 0, width: cameraViewPhotoSize.width, height: cameraViewPhotoSize.height))!)
                            
                        }
                    }
                }
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        //                print(sampleBuffer)
        
    }
    
    
    
    // AVCapturePhotoCaptureDelegate method for Image Saving
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let image = previewImageView.image {
            
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                
                //설정 - 사진 승인 상태이기에 앨범에 저장 후에 이동
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
                
            case .denied, .notDetermined:
                
                //설정 - 사진 미승인 상태이기에 앨범에 저장 하지 않고 다음 화면으로 이동
                performSegue(withIdentifier: CameraViewController.showEditPhotoViewControllerSegueIdentifier, sender: self)
                
            default:
                return
            }
        }
        
    }
    
    // UIImageWriteToSavedPhotosAlbum 메소드 수행 후에 completionSelector
    //    func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
    
    func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        if(error != nil) {
            return
        }
        
        performSegue(withIdentifier: CameraViewController.showEditPhotoViewControllerSegueIdentifier, sender: self)
        
    }
    
    
    
    
    // MARK:- Permission Check
    
    func checkCameraPermission() {
        // 카메라 하드웨어 사용가능 여부 판단.
        let availableCameraHardware:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
        shutterOfCameraBarButtonItem.isEnabled = availableCameraHardware
        authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if let authorizationStatusOfCamera = authorizationStatus, availableCameraHardware {
            switch authorizationStatusOfCamera {
                
            case .authorized:
                print(authorizationStatusOfCamera)
                setUpCamera() // 카메라 setup
                
            case .denied:
                showNotice(alertCase: .camera) // 접근 권한이 없으므로 사용자에게 설정 - DailyMoments - 카메라 허가 요청 UIAlertController 호출
                
                disableCameraOptionButton() // 플래쉬, 스위칭 버튼 disabled
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler : { (granted: Bool) in
                    
                    if granted {
                        
                        // GCD
                        DispatchQueue.main.async {
                            self.setUpCamera() // 카메라 setup
                        }
                        
                    } else {
                        print(granted)
                        
                        // GCD
                        DispatchQueue.main.async {
                            self.disableCameraOptionButton() // 플래쉬, 스위칭 버튼 disabled
                        }
                    }
                })
                
            case .restricted:
                print(authorizationStatusOfCamera)
            }
        }
    }
    
    func showNotice(alertCase : SettingType){
        
        let alertController = UIAlertController(title: AlertContentConstant.titles[alertCase.rawValue], message: AlertContentConstant.messages[alertCase.rawValue], preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: AlertContentConstant.setting, style: .default, handler: { (action:UIAlertAction) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl!)
            }
        }))
        alertController.addAction(UIAlertAction(title: AlertContentConstant.cancel, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK:- Screen Ratio
    
    // AVCaptureDevice 종류와 선택한 스크린 사이즈 비율에 맞게 PreviewImageView Frame 변경
    func getSizeByScreenRatio(with cameraPosition: AVCaptureDevicePosition, at screenRatioStatus: Int){
        var photoWidth: CGFloat?
        var photoHeight: CGFloat?
        
        var rectOfpreviewImage: CGRect?
        
        photoWidth = ScreenType.photoWidthByDeviceInput(type: cameraPosition.rawValue)
        photoHeight = ScreenType.photoHeightByAspectScreenRatio(cameraPosition.rawValue, ratioType: screenRatioStatus)
        
        rectOfpreviewImage = ScreenType.getCGRectPreiewImageView(target: UIScreen.main.bounds, yMargin: settingToolbar.frame.height, ratioType: screenRatioStatus)
        
        
        if let photoWidth = photoWidth, let photoHeight = photoHeight, let rectOfpreviewImage = rectOfpreviewImage {
            cameraViewPhotoSize = CameraViewPhotoSize(width: photoWidth, height: photoHeight)
            DispatchQueue.main.async {
                self.previewImageView.frame = rectOfpreviewImage
            }
            
            
        }
    }
    
    // MARK:- generate preview Photo
    
    // 작은 크기로 보여줄 UIImage를 생성하는 메소드. crop Image -> resize Image
    func generatePreviewPhoto(source image: UIImage?) -> UIImage? {
        
        if let image = image  {
            let widthOfscreenSize:CGFloat = UIScreen.main.bounds.width
            let valueToDivideTheScreen:CGFloat = CGFloat.init(cellUnitValue)
            let widthOfImage = widthOfscreenSize / valueToDivideTheScreen
            
            let croppedImage: UIImage = image.cropToSquareImage()
            
            return croppedImage.resizeImage(targetSize: CGSize(width: widthOfImage, height: widthOfImage))
        }
        return UIImage()
    }
    
    
    
    
    // MARK:- FocusMode, draw and move focus Box.
    
    // 초점 맞추기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 포토 라이브러리에서 이미지를 가져온 경우 return
        if photoMode == .photoLibrary {
            return
        }
        
        
        if let coordinates = touches.first, let device = captureDevice {
            
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
                        changeFocusBoxCenter(for: coordinates.location(in: previewImageView))
                    } else {
                        // 초점 박스가 없으면 그려줌
                        makeRectangle(at : coordinates)
                    }
                    
                    previewImageView.addSubview(self.focusBox)
                    fadeViewInThenOut(view: self.focusBox, delay: PhotoEditorTypes.filterNameLabelAnimationDelay)
                } catch{
                    fatalError()
                }
            }
            // 전면 카메라에서는 FocusPointOfInterest 를 지원하지 않는다.
            
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    // 초점 박스를 이동하는 메소드
    func changeFocusBoxCenter(for location: CGPoint )
    {
        self.focusBox.center.x = location.x
        self.focusBox.center.y = location.y
    }
    
    func touchPercent(touch coordinates: UITouch) -> CGPoint {
        
        // 0~1.0 으로 x, y 화면대비 비율 구하기
        let x = coordinates.location(in: previewImageView).y / previewImageView.bounds.height
        let y = 1.0 - coordinates.location(in: previewImageView).x / previewImageView.bounds.width
        let ratioOfPoint = CGPoint(x: x, y: y)
        
        return ratioOfPoint
    }
    
    
    func makeRectangle(at coordinates : UITouch) {
        
        // 화면 사이즈 구하기
        let screenBounds = previewImageView.bounds
        
        // 화면 비율에 맞게 정사각형의 focus box 그리기
        var rectangleBounds = screenBounds
        rectangleBounds.size.width = screenBounds.size.width / 5
        rectangleBounds.size.height = screenBounds.size.width / 5
        
        // 터치된 좌표에 focusBox의 높이, 너비의 절반 값을 빼주어서 터치한 좌표를 중심으로 그려지게 설정
        rectangleBounds.origin.x = coordinates.location(in: previewImageView).x - (rectangleBounds.size.width / 2)
        rectangleBounds.origin.y = coordinates.location(in: previewImageView).y - (rectangleBounds.size.height / 2)
        
        self.focusBox = UIView(frame: rectangleBounds)
        self.focusBox.layer.borderColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 1).cgColor
        self.focusBox.layer.borderWidth = 0.5
        
    }
    
    
    
    // MARK: - Filter Name Label FadeOut Animation
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        // 포토 라이브러리에서 이미지를 가져온 경우 return
        if photoMode == .photoLibrary {
            return
        }
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0
                
            },
                           completion: nil)
        }
    }
    
    
}
