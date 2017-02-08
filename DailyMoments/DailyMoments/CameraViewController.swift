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
    var captureSession:AVCaptureSession?
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true // status bar hide
    }
    
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        
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
                                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                    
                                    previewLayer.connection.videoOrientation = .portrait
                                    
                                   
                                    cameraView.layer.addSublayer(previewLayer)
                                    
                                    previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                                    previewLayer.frame = cameraView.bounds
                                    let previewLayerHeight = previewLayer.bounds.height
                                    let cameraViewLayoutHeight = cameraView.bounds.height
                                    
                                    
                                    print("previewLayerHeight: \(previewLayerHeight)")
                                    print("cameraViewLayoutHeight: \(cameraViewLayoutHeight)")
                                    
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
    
    @IBAction func cancelTakePhoto(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        
        sessionOutput.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
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

