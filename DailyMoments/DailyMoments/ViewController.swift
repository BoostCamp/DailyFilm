
func takePhoto(sender : UITapGestureRecognizer){
    print("1")
}

//
//  ViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 6..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraShutterButtonImageView: UIImageView!


    
    // 참고할 문서.
    // https://developer.apple.com/library/prerelease/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html
    var captureSession:AVCaptureSession?
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true // status bar hide
        cameraShutterButtonImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "switch_position"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(switchCameraPostion))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        
        navigationController?.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        captureSession = AVCaptureSession()
    }

    
    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let session = captureSession {
//            session.sessionPreset = AVCaptureSessionPreset1920x1080
            
            let photoShootGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
            cameraShutterButtonImageView.addGestureRecognizer(photoShootGestureRecognizer)
            
            
            
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
                                    previewLayer.bounds = cameraView.frame
                                    
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
    
    
    // MARK: Swipe Gesture & Navigation
    
    
    @IBAction func swipeGestureForNavigation(_ sender: Any) {
        if let swipeGesture = sender as? UISwipeGestureRecognizer {
            switch swipeGesture.direction{
            case UISwipeGestureRecognizerDirection.right:
               
                print("right")
            case UISwipeGestureRecognizerDirection.left:
                print("left")
//                guard let diaryTableViewController = storyboard?.instantiateViewController(withIdentifier: "DiaryTableView") as? DiaryTableViewController
//                    else{
//                        print("navigate fail")
//                        return
//                }
//                navigationController?.pushViewController(diaryTableViewController, animated: true)
            default:
                break
            }
        }
    }
    
    
    // MARK: general function
    
    
    
    func takePhoto(sender : UITapGestureRecognizer){
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
    
        sessionOutput.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    
    func switchCameraPostion(sender : UITapGestureRecognizer){
        //        captureSession.beginConfiguration()
        //        let currentCemeraInput:AVCaptureInput = captureSession.inputs.first as! AVCaptureInput
        //        captureSession.removeInput(currentCemeraInput)
        //        usingCamera(AVCaptureDevicePosition.front)
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
                } else if(input.device.position == .front){
                        newCamera = cameraWithPosition(position: .back)
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
            
            if(newVideoInput == nil || err != nil)
            {
                print("Error creating capture device input: \(err!.localizedDescription)")
            }
            else
            {
                session.addInput(newVideoInput)
            }
            
            //Commit all the configuration changes at once
            session.commitConfiguration()
            
            
        }
    }
    
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
    
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let takedPhotoImage = UIImage(data: photoData!)
            
            if let image = takedPhotoImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}

