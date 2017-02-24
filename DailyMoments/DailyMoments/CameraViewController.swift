//
//  CameraViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 6..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation
import Dispatch


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, pickedImageSentDelegate {
    
    
    @IBOutlet weak var filterNameLabel: UILabel!
    
    @IBOutlet weak var settingToolbar: UIToolbar! // 취소, 화면 비율, 플래쉬 버튼이 있는 툴바
    @IBOutlet weak var cameraToolbar: UIToolbar! // 사진앨범, 셔터, 전후면 카메라스위치 버튼이 있는 툴바
    
    @IBOutlet weak var screenRatioBarButtonItem: UIBarButtonItem! // 스크린 화면 비율을 위한 버튼 (1:1, 3:4, 9:16)
    
    @IBOutlet weak var flashOfCameraBarButtonItem: UIBarButtonItem! // 카메라 플래쉬 버튼
    
    @IBOutlet weak var photoAlbumBarButton: UIBarButtonItem! // 포토앨범으로 가는 버튼
    
    @IBOutlet weak var shutterOfCameraBarButtonItem: UIBarButtonItem! // 카메라 셔터(촬영) 버튼
    
    @IBOutlet weak var switchOfCameraBarButtonItem: UIBarButtonItem! // 전면/후면카메라 스위치 버튼
    
    @IBOutlet weak var previewImageView: UIImageView! // 렌즈(input)에서 얻어지는 샘플 데이터를 디스플레이 화면에서 보여주기 위한 view
    
    @IBOutlet weak var addFunEmoticonBarButton: UIBarButtonItem!
    
    var focusBox: UIView!
    
    var funFaceIcon: UIImageView?
    
    var isAddFunEmoticon: Bool?
    
    var originalPhotoImage: UIImage?
    
    var filterName: String? // CIFilter를 적용할 때 필요한 필터 이름
    
    var filterIndex: Int? // 스와이프로 필터를 선택 시에 현재 필터 인덱스를 저장할 프로퍼티
    
    var cameraPosition: AVCaptureDevicePosition? // 카메라 포지션을 저장할 프로퍼티
    
    var cameraFlashSwitchedStatus: Int = 0 // FlashMode 구분을 위한 저장 프로퍼티
    
    var screenRatioSwitchedStatus: Int = 0 // 화면 비율 구분을 위한 저장 프로퍼티
    
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    
    var photoMode: AddPhotoMode? // 카메라, 사진앨범 모드인지 구분하는 저장 프로퍼티
    
    
    
    var cameraRelatedCoreImageResource: CameraRelatedCoreImageResource? // Video Data Output, Sample Data struct
    
    var faceDetectRelatedResource: FaceDetectRelatedResource? // Face Recognition struct
    
    var imageOptions: [String: AnyObject]?
    
    // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티
    var cameraViewPhotoSize: CameraViewPhotoSize?
    
    // 참고할 문서.
    // https://developer.apple.com/library/prerelease/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/04_MediaCapture.html
    
    // You use an AVCaptureSession object to coordinate the flow of data from AV input devices to outputs.
    
    var captureDevice: AVCaptureDevice? // AVCaptureDevice 객체는 물리적 캡처 장치와 해당 장치와 관련된 속성을 나타냅니다. 캡처 장치를 사용하여 기본 하드웨어의 속성을 구성합니다. 캡처 장치는 또한 AVCaptureSession 객체에 입력 데이터 (예 : 오디오 또는 비디오)를 제공합니다.
    
    var captureSession: AVCaptureSession? // AV 입력장치에서 출력으로의 데이터 흐름을 조정하는 AVCaptureSession 객체입니다.
    
    var photoOutput: AVCapturePhotoOutput? // 스틸 사진과 관련된 대부분의 캡처 워크 플로에 대한 최신 인터페이스를 제공하는 AVCaptureOutput의 구체적인 하위 클래스입니다.
    
    var videoDataOutput: AVCaptureVideoDataOutput? // AVCaptureVideoDataOutput은 캡처중인 비디오에서 압축되지 않은 프레임을 처리하거나 압축 된 프레임에 액세스하는 데 사용하는 AVCaptureOutput의 구체적인 하위 클래스입니다. AVCaptureVideoDataOutput 인스턴스는 다른 미디어 API를 사용하여 처리 할 수있는 비디오 프레임을 생성합니다. captureOutput (_ : didOutputSampleBuffer : from :)
    
    var settingsForMonitoring: AVCapturePhotoSettings? // 단일 사진 캡처 요청에 필요한 모든 기능과 설정을 설명하는 변경 가능한 객체입니다.
    
    var authorizationStatus: AVAuthorizationStatus? // Camera 접근 권한을 위한 저장 프로퍼티
    
    var context: CIContext? // openGL ES3 api를 사용하여 CGImage를 생성하기 위함. iOS7, 3gs, 아이팟터치 3세대 이후 지원하며 3D 라이브러리 중 하나이다. (OpenGL ES (임베디드 단말을 위한 OpenGL)는 크로노스 그룹이 정의한 3차원 컴퓨터 그래픽스 API인 OpenGL의 서브셋으로, 휴대전화, PDA 등과 같은 임베디드 단말을 위한 API이다.)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true // status bar hide

        
        //Init Setting
        isAddFunEmoticon = false
        photoMode = .camera
        cameraFlashSwitchedStatus = FlashModeConstant.off.rawValue // Init
        cameraPosition = .back // default는 back camera
        screenRatioSwitchedStatus = 0 // 1:1 Ratio
        
        if let cameraPosition = cameraPosition {
          
            // 초기 셋팅, back camera and 1:1 ratio 
            // cameraPosition = .back
            // screenRatioSwitchedStatus = 0 //square
            getSizeByScreenRatio(with: cameraPosition, at: screenRatioSwitchedStatus)
            
        }
        
        
        filterIndex = 0
        if let filterIndex = filterIndex {
            filterName = PhotoEditorTypes.filterNameArray[filterIndex]
        }
        
        
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        videoDataOutput = AVCaptureVideoDataOutput()
        
        // openGL ES3 로 이미지를 렌더링할 context 생성
        // About OpenGL ES - https://developer.apple.com/library/prerelease/content/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008793
        // About Core Image - https://developer.apple.com/library/prerelease/content/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185

    
        let openGLContext = EAGLContext(api: .openGLES3)
        context = CIContext(eaglContext: openGLContext!)
        
    
        cameraRelatedCoreImageResource = CameraRelatedCoreImageResource()
        faceDetectRelatedResource = FaceDetectRelatedResource()
        faceDetectRelatedResource?.faceDetector = CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        imageOptions =  NSDictionary(object: NSNumber(value: 2) as NSNumber, forKey: CIDetectorImageOrientation as NSString) as? [String : AnyObject]
        // let kCGImagePropertyOrientation: CFString
        // 1 Top, right -> front
    }
    
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in CameraViewController")
        
        // toolbar hide
        navigationController?.isToolbarHidden = true
        
        // navigationbar hide
        navigationController?.navigationBar.isHidden = true
        
        
        // cameraToolbar, settingToolbar transparent
        cameraToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        cameraToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        settingToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        settingToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        // Camera Permission 체크
        checkCameraPermission()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in CameraViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in CameraViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in CameraViewController")
    }
    
    
    
    // MARK:- Change Camera Effect Filter From Swipe Gesture
    
    @IBAction func changeCameraEffectWithSwipeGesture(_ sender: Any) {
        
        if let swipeGesture = sender as? UISwipeGestureRecognizer{
            
            // swipe gesture를 통해서 필터 종류를 카메라 상태에서 변경
            switch swipeGesture.direction {
                
            // right, left 제스처 direction에 맞게 filterIndex를 -, +, %를 활용해서 필터 선택 인덱스를 계산.
            case UISwipeGestureRecognizerDirection.right:
                
                filterIndex = (filterIndex! - 1) % PhotoEditorTypes.numberOfFilterType()
                if filterIndex! < 0 {
                    filterIndex = filterIndex! + PhotoEditorTypes.numberOfFilterType()
                }
                
            case UISwipeGestureRecognizerDirection.left:
                
                filterIndex = (filterIndex! + 1) % PhotoEditorTypes.numberOfFilterType()
                
            default:
                return
            }
            
            if let filterIndex = filterIndex {
                
                filterName = PhotoEditorTypes.filterNameArray[filterIndex]
                if let filterName = filterName {
                    filterNameLabel.text = filterName.replacingOccurrences(of: PhotoEditorTypes.replacingOccurrencesWord, with: "")
                }
            }
            
            fadeViewInThenOut(view: filterNameLabel, delay: PhotoEditorTypes.filterNameLabelAnimationDelay)
        }
    }
    
    
    
    @IBAction func addFunEmoticon(_ sender: Any) {
        
       
        
        if cameraPosition == .front {
            isAddFunEmoticon = !isAddFunEmoticon!

            if funFaceIcon == nil {
                self.funFaceIcon = UIImageView(image: UIImage(named: "line_brown"))

                previewImageView.addSubview(funFaceIcon!)

            } else {
                funFaceIcon?.removeFromSuperview()
                funFaceIcon = nil
            }
            
        }

    }
    
 
    // MARK: - 카메라 비율 변경

    @IBAction func switchScreenRatio(_ sender: Any) {
        
        // 0: 1:1, 1: 3:4, 2: 9:16
        screenRatioSwitchedStatus += 1
        screenRatioSwitchedStatus %= ScreenType.numberOfRatioType()
        if let cameraPosition = cameraPosition {
            
            switch screenRatioSwitchedStatus {
            case  ScreenType.Ratio.square.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_1")
                
            case ScreenType.Ratio.retangle.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_33")
                
            case ScreenType.Ratio.full.rawValue :
                screenRatioBarButtonItem.image = UIImage(named: "screen_ratio_1_77")
                
            default:
                break;
            }

            // 화면 비율이 스위칭 될 때 screen Size를 새로 구해오기 위함
            getSizeByScreenRatio(with: cameraPosition, at: screenRatioSwitchedStatus)
           
        }
    }
    
    // MARK:- Flash Mode

    @IBAction func switchCameraFlash(_ sender: Any) {
   
        
        // 사진 앨범에서 이미지를 가져온 왔을 때, 플래쉬 버튼을 누르면 다음 화면 이동
        if photoMode == .photoLibrary {
            performSegue(withIdentifier: CameraViewController.showEditPhotoViewControllerSegueIdentifier, sender: self)
        }
        
        
        // 0: off, 1: on, 2: auto
        cameraFlashSwitchedStatus += 1
        cameraFlashSwitchedStatus %= 3
   
        switch cameraFlashSwitchedStatus {
        case FlashModeConstant.off.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "flash_off")
        case FlashModeConstant.on.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "flash_on")
        case FlashModeConstant.auto.rawValue:
            flashOfCameraBarButtonItem.image = UIImage(named: "flash_auto")
        default:
            break;
        }
        
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

    // MARK:- 촬영 취소, 카메라 모달 뷰 내리기
    @IBAction func cancelTakePhoto(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - 촬영, 저장
    @IBAction func takePhoto(_ sender: Any) {
        authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if let authorizationStatusOfCamera = authorizationStatus {
            
            
            print(authorizationStatusOfCamera.rawValue)
            
            switch authorizationStatusOfCamera {
            case .authorized:
                
                settingsForMonitoring = AVCapturePhotoSettings()
                
                DispatchQueue.main.async {
                    if let photoCaptureSetting = self.settingsForMonitoring, let capturePhotoOutput = self.photoOutput{
                        
                        
                        let previewPixelType = photoCaptureSetting.availablePreviewPhotoPixelFormatTypes.first!
                        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                             kCVPixelBufferWidthKey as String: 160,
                                             kCVPixelBufferHeightKey as String: 160]
                        photoCaptureSetting.previewPhotoFormat = previewFormat
                        
                        
                        
                        photoCaptureSetting.flashMode = self.getCurrentFlashMode(self.cameraFlashSwitchedStatus)
                        
                        // 자동 안정화 이미지 여부, default는 true
                        
                        photoCaptureSetting.isAutoStillImageStabilizationEnabled = true
                        
                        // 활성 장치 및 형식에서 지원하는 최고 해상도로 스틸 이미지를 캡처할지 여부를 지정. default는 false
                        photoCaptureSetting.isHighResolutionPhotoEnabled = false
                        
                        capturePhotoOutput.capturePhoto(with: photoCaptureSetting, delegate: self)
                    }
                }
                
            case .denied:
                print(authorizationStatusOfCamera)
                showNotice(alertCase: .camera)
            default:
                return
                
            }
        }
    }
    
    
    // MARK: - front/back camera swiching
    
    @IBAction func switchCameraPostion(_ sender: Any) {
        if let session = captureSession {
            // Indicate that some changes will be made to the session
            
            session.beginConfiguration()
            
            let availableCameraHardware:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
            
            // 카메라 하드웨어 사용 불가하면 return 
            if availableCameraHardware == false {
                return
            }
            
            // Remove existing input
            let currentCameraInput:AVCaptureInput = session.inputs.first as! AVCaptureInput
            session.removeInput(currentCameraInput)
            
            captureDevice = nil
            
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if(input.device.position == .back){
                    captureDevice = cameraWithPosition(position: .front)
                    cameraPosition = .front
                    session.sessionPreset = AVCaptureSessionPreset1280x720
                    
                } else if(input.device.position == .front){
                    captureDevice = cameraWithPosition(position: .back)
                    cameraPosition = .back
                    session.sessionPreset = AVCaptureSessionPreset1920x1080
                }
                
            }
            
            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: captureDevice)
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
         
            if let cameraPosition = cameraPosition {
                
                // 카메라 스위칭 될 때 screen Size를 새로 구해오기 위함
                getSizeByScreenRatio(with: cameraPosition, at: screenRatioSwitchedStatus)
              
                
            }
        }
    }
    
    
    func removeCurrentCaptureInput(){
        
        let availableCameraHardware:Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if let session = captureSession, availableCameraHardware == true {
            
            session.beginConfiguration()
            // Remove existing input
            let currentCameraInput:AVCaptureInput = session.inputs.first as! AVCaptureInput
            session.removeInput(currentCameraInput)
            session.commitConfiguration()
        }
    }
    
    
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        for device in (deviceSession?.devices)! {
            
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    
    
    
    // MARK:- update post (custom delegate)
    
    
    func setPickedImageFromPhotoAlbum(pickedImage: UIImage?, photoMode: AddPhotoMode){
       
        self.photoMode = photoMode

        switch photoMode {

        case .camera:
            setUpCamera()
            
        case .photoLibrary:
            if let pickedImage = pickedImage {
                self.previewImageView.image = pickedImage
                originalPhotoImage = pickedImage
                
            }
        }
    }
    
    
    // MARK:- Navigate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CameraViewController.showEditPhotoViewControllerSegueIdentifier, let editPhotoViewController = segue.destination as? EditPhotoViewController{
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            
            editPhotoViewController.cameraRelatedCoreImageResource = cameraRelatedCoreImageResource
            editPhotoViewController.selectedFilterIndex = filterIndex
            
            
        }
        else if segue.identifier == CameraViewController.showPhotoAlbumCollectionViewSegueIdentifier, let photoAlbumCollectionViewController = segue.destination as? PhotoAlbumCollectionViewController {
            photoAlbumCollectionViewController.sizeOfImage = previewImageView.frame.size
            photoAlbumCollectionViewController.delegate = self
            

        }
    }

    
    // MARK:- 포토라이브러리에서 사진 pick
    
    @IBAction func pickAnImageFromPhotoLibrary(_ sender: Any) {
        removeCurrentCaptureInput()
        
        photoMode = .photoLibrary
        self.performSegue(withIdentifier: CameraViewController.showPhotoAlbumCollectionViewSegueIdentifier, sender: self)

    }
}

