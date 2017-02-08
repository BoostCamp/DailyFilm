//
//  CameraViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 6..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraToolbar: UIToolbar! // 플래쉬, 셔터, 전후면 카메라스위치 버튼이 있는 툴바
    @IBOutlet weak var flashOfCameraBarButtonItem: UIBarButtonItem! // 카메라 플래쉬 버튼
    @IBOutlet weak var shutterOfCameraBarButtonItem: UIBarButtonItem! // 카메라 셔터(촬영) 버튼
    @IBOutlet weak var switchOfCameraBarButtonItem: UIBarButtonItem! // 전면/후면카메라 스위치 버튼
    
    
    
    // 참고할 문서.
    // https://developer.apple.com/library/prerelease/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html
    
    // You use an AVCaptureSession object to coordinate the flow of data from AV input devices to outputs.
    var captureSession: AVCaptureSession? // AV 입력장치에서 출력으로의 데이터 흐름을 조정하는 AVCaptureSession 객체입니다.
    var sessionOutput: AVCapturePhotoOutput? // 스틸 사진과 관련된 대부분의 캡처 워크 플로에 대한 최신 인터페이스를 제공하는 AVCaptureOutput의 구체적인 하위 클래스입니다.
    var previewLayer: AVCaptureVideoPreviewLayer? // 입력 장치에서 캡처 한 비디오를 표시하는 데 사용하는 CALayer의 하위 클래스입니다. AVCapureSession과 함께 사용합니다.
    var settingsForMonitoring: AVCapturePhotoSettings? // 단일 사진 캡처 요청에 필요한 모든 기능과 설정을 설명하는 변경 가능한 객체입니다.
    
    var cameraFlashSwitchedStatus: Int = 0 // FlashMode 구분을 위한 저장 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true // status bar hide
        cameraFlashSwitchedStatus = FlashModeConstant.off.rawValue // Init
        
    }
    
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        sessionOutput = AVCapturePhotoOutput()
        previewLayer = AVCaptureVideoPreviewLayer()

        if let session = captureSession {
            session.sessionPreset = AVCaptureSessionPreset1920x1080
            
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
                    
                    if discoveredDevice.position == AVCaptureDevicePosition.back {
                        do {
                            let input = try AVCaptureDeviceInput(device: discoveredDevice)
                            if session.canAddInput(input){
                                session.addInput(input)
                                
                                if session.canAddOutput(sessionOutput){
                                    session.addOutput(sessionOutput)
                                    
                                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                                    
                                    if let captureVideoPreviewLayer = previewLayer{
                                        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                        captureVideoPreviewLayer.connection.videoOrientation = .portrait
                                        
                                        cameraView.layer.addSublayer(previewLayer!)
                                        
                                        captureVideoPreviewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                                        captureVideoPreviewLayer.frame = cameraView.bounds
                                        
                                        session.startRunning()
                                    }
                                    
                                }
                                
                            }
                        } catch let avCaptureError {
                            print(avCaptureError)
                        }
                    }
                } // End of find device
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // MARK:- IBAction
    
    
    @IBAction func switchCameraFlash(_ sender: Any) {
        // 0: off, 1: on, 2: auto
        cameraFlashSwitchedStatus += 1
        cameraFlashSwitchedStatus %= 3
        
        switch cameraFlashSwitchedStatus {
        case FlashModeConstant.off.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "camera_flash_off")
        case FlashModeConstant.on.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "camera_flash_on")
        case FlashModeConstant.auto.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "camera_flash_auto")
        default:
            break;
        }
    }
    
    
    @IBAction func swtichCameraEffect(_ sender: Any) {
    
        if let swipeGesture = sender as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                print("Left Swipe")
            case UISwipeGestureRecognizerDirection.right:
                print("Right Swipe")
            default:
                return
            }
        }
    }
    
    
    // 카메라 모달 뷰 내리기
    @IBAction func cancelTakePhoto(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // 촬영하기
    @IBAction func takePhoto(_ sender: Any) {
        settingsForMonitoring = AVCapturePhotoSettings()
        
        if let photoCaptureSetting = settingsForMonitoring, let capturePhotoOutput = sessionOutput{
            
            photoCaptureSetting.flashMode = getCurrentFlashMode(cameraFlashSwitchedStatus)
            photoCaptureSetting.isAutoStillImageStabilizationEnabled = true
            photoCaptureSetting.isHighResolutionPhotoEnabled = false
            
            capturePhotoOutput.capturePhoto(with: photoCaptureSetting, delegate: self)
        }
    }
    
    // 전면/후면 카메라 스위칭
    @IBAction func switchCameraPostion(_ sender: Any) {
        if let session = captureSession {
            // Indicate that some changes will be made to the session
            session.beginConfiguration()
            
            // Remove existing input
            let currentCameraInput:AVCaptureInput = session.inputs.first as! AVCaptureInput
            session.removeInput(currentCameraInput)
            
            // Get new input
            var newCamera:AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if(input.device.position == .back){
                    newCamera = cameraWithPosition(position: .front)
                    session.sessionPreset = AVCaptureSessionPreset1280x720
                    
                } else if(input.device.position == .front){
                    newCamera = cameraWithPosition(position: .back)
                    session.sessionPreset = AVCaptureSessionPreset1920x1080
                }
            }
            
            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }
            
            if(newVideoInput == nil || err != nil) {
                print("Error creating capture device input: \(err!.localizedDescription)")
            } else {
                session.addInput(newVideoInput)
            }
            
            //Commit all the configuration changes at once
            session.commitConfiguration()
            
        }
    }

    
    // MARK:- general function

    
    
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice?
    {
        
        
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        for device in (deviceSession?.devices)! {
            
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    // AVCapturePhotoCaptureDelegate method for Image Saving
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let takedPhotoImage = UIImage(data: photoData!)
            
            if let image = takedPhotoImage {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
            }
        }
    }
    
    // UIImageWriteToSavedPhotosAlbum 메소드 수행 후에 completionSelector
    func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        dump(image)
    }
}

extension CameraViewController {
    
    enum FlashModeConstant: Int {
        case off
        case on
        case auto
    }
    
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
    
}

