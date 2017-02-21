//
//  AddContentViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 13..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import CoreLocation

class AddContentViewController: UIViewController {
    
    
    @IBOutlet weak var createdDate: UILabel! // 촬영된 시간
    @IBOutlet weak var addressLabel: UILabel! // 촬영된 주소
    @IBOutlet weak var previewOfPhotoToPostImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var edidtedPhotoImage: UIImage? // 필터가 적용된 Image
    var takenResizedPhotoImage: UIImage? // 촬영한 Image를 reszie
    
    
    var nowDate: Date?
    var timeIntervalOfCreatedDate: TimeInterval?
    var intValueOfCreatedDate: TimeInterval?  //1487227355.6198459 ->  1487227355.0
    var imageFileName: String? // 저장될 파일 이름
    
    let manager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentPlacemark: CLPlacemark?
    var address: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Date 생성
        
        let date: Date = Date()
        //Calendar Component에 맞게 Date 변환
        nowDate = date.getDateComponents()
        if let nowDate = nowDate {
            
            // 현재 시간 기준으로 timeIntervalSince1970 추출
            timeIntervalOfCreatedDate = nowDate.timeIntervalSince1970
            
            //1487227355.6198459 ->  1487227355.0
            intValueOfCreatedDate = Double(Int(timeIntervalOfCreatedDate!))
            
            //파일 네임 set
            imageFileName = nowDate.makeName()
            createdDate.text = nowDate.toString()
            
        }
        
        
        
        
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
            currentLocation = nil
            currentPlacemark = nil
            
        } else {
            print("Location services are not enabled");
        }
        
        // center crop -> resize하여 view에 보여줌.
        
        if let previewPhoto = generatePreviewPhoto(source: edidtedPhotoImage) {
            previewOfPhotoToPostImageView.image = previewPhoto
        }
        
        // rightBarButton인 Done버튼 tint색을 애플의 파란색으로 변경
        navigationItem.rightBarButtonItem?.tintColor = UIColor.appleBlue()
        
        contentTextView.delegate = self
    }
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false

        // UIKeyboardWillShow, UIKeyboardWillHide이벤트 통지 가입 (NSNotification.Name)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UIKeyboardWillShow, UIKeyboardWillHide이벤트 통지 해제 (NSNotification.Name)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    
    
    
    func savePostInfo(_ userIndex: Int32, completion: ((_ success:Bool) -> Void)?){
        
      
        
        
        let content: String? = self.contentTextView.text
        
        let isFavorite: Int32? = 0
        
        var latitude: Float?
        var longitude: Float?
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            latitude  = Float((self.currentLocation?.coordinate.latitude)!)
            longitude = Float((self.currentLocation?.coordinate.longitude)!)
            
        } else if CLLocationManager.authorizationStatus() == .denied {
            latitude = 0
            longitude = 0
            
        }
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        //file Path 추가하여 생성
        let documentDirectoryPathURL = URL(fileURLWithPath: documentDirectoryPath)
        
        
        // 필터 적용된 이미지(UIImage?)의 옵셔널 바인딩
        if let editedImage = self.edidtedPhotoImage, let imageFileName = imageFileName {
            let editedImageURL = documentDirectoryPathURL.appendingPathComponent(imageFileName)
            
            do {
                try UIImagePNGRepresentation(editedImage)?.write(to: editedImageURL, options: Data.WritingOptions.atomic)
                
            } catch {
                return
            }
        }
        
        if let imageFileName = imageFileName, let content = content, let isFavorite = isFavorite, let createdDate = intValueOfCreatedDate, let address = address, let latitude = latitude, let longitude = longitude {
            let post = Post(postIndex: 0, userIndex: userIndex, imageFilePath: imageFileName, content: content, isFavorite: isFavorite, createdDate: createdDate, address: address, latitude: latitude, longitude: longitude)
            
            let successFlag:Bool = FMDatabaseManager.shareManager().insert(query: Statement.Insert.post, valuesOfColumns: [post.userIndex as Any, post.imageFilePath as Any, post.content as Any, post.isFavorite as Any, post.createdDate as Any, post.address as Any, post.createdDate as Any, post.latitude as Any, post.longitude as Any])
            
            completion?(successFlag)
            
        }
    }
    
    
    // 작은 크기로 보여줄 UIImage를 생성하는 메소드. crop Image -> resize Image
    func generatePreviewPhoto(source image: UIImage?) -> UIImage? {
        
        if let image = image {
            
            let widthOfscreenSize:CGFloat = UIScreen.main.bounds.width
            let valueToDivideTheScreen:CGFloat = CGFloat.init(cellUnitValue)
            let widthOfImage = widthOfscreenSize / valueToDivideTheScreen
            let cropedImage: UIImage = image.cropToSquareImage()
            
            return cropedImage.resizeImage(targetSize: CGSize(width: widthOfImage, height: widthOfImage))
        }
        return UIImage()
    }
    
    
    @IBAction func completedPosting(_ sender: Any) {
        
        let userProfiles:[UserProfile] = FMDatabaseManager.shareManager().selectUserProfile(query: Statement.Select.userProfile, value: "nso502354@gamil.com")
        
        let userIndex:Int32? = userProfiles[0].userIndex
        
        if let userIndex = userIndex {
            savePostInfo(userIndex, completion: { (success:Bool) in
                
                if success {
                    self.dismissKeyboard()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // 실패시
                    print("posting fail")
                }
            
            })
        }
    }
    
    
    @IBAction func addContent(_ sender: Any) {
        
        if let buttonType = sender as? UIBarButtonItem {
            
            switch buttonType.tag {
            case ContentType.location.rawValue :
                
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    
                    /*
                    if let currentLocation = currentLocation {
                        reverseGeocodingRequestForSpecifiedLocation(location: currentLocation)
                    }
                    */
                    if let address = address {
                        contentTextView.insertText(address)
                    }
                    
                    
                } else if CLLocationManager.authorizationStatus() == .denied {
                    showNotice(alertCase: .location)
                }
                
                
            case ContentType.time.rawValue :
                
                if let nowDate = nowDate {
                    contentTextView.insertText(nowDate.getDateString())
                }
                
            
            case ContentType.favorite.rawValue :
                print("위시리스트 설정 여부")
            default:
                return
            }
            
            
        }
    }
    
}


// UITextViewDelegate & keyboard show/hide

extension AddContentViewController: UITextViewDelegate {
    
    
    enum ContentType: Int {
        case location = 0
        case time
        case favorite
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        addContentTypeButtonOnKeyboard()

        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        
//        if contentTextView.inputAccessoryView == nil {
//            print("textViewDidBeginEditing addContentTypeButtonOnKeyboard")
//            addContentTypeButtonOnKeyboard()
//        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldEndEditing")
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("textViewDidChangeSelection")

    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
    }
    
    
    // MARK: keyboard control function
    
    
    func keyboardWillShow(_ notification:Notification){

        // keyboard가 show될 때
        
        if contentTextView.isFirstResponder {
            
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        
        // keyboard가 hide될 때
        
        if contentTextView.isFirstResponder{

        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        //NSNotification에는 딕셔너리 형태의 userInfo 프로퍼티가 있습니다. userInfo 프로퍼티를 이용하여 키보드의 위치와 크기를 가져올 수 있습니다.
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        // 옵저버 등록 , The notification object is nil from UIKeyboardWillShow, UIKeyboardWillHide of apple developer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        // 옵저버 해제
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func addContentTypeButtonOnKeyboard() {
        
        let screenWidthSize:CGFloat = UIScreen.main.bounds.width
        
        let locationImage: UIImage? = UIImage(named: "location")
        let timeImage: UIImage? = UIImage(named: "time")
        let favoriteImage: UIImage? = UIImage(named: "favorite")
        let keyboardHideImage: UIImage? = UIImage(named: "keyboard_hide")
        
        let contentTypeToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidthSize, height: 44))
        contentTypeToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let locationBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: locationImage, style: .plain, target: self, action: #selector(addContent(_:)))
        locationBarButtonAtAccesoryView.tag = ContentType.location.rawValue
        
        let timeBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: timeImage, style: .plain, target: self, action: #selector(addContent(_:)))
        timeBarButtonAtAccesoryView.tag = ContentType.time.rawValue
        
        let favoriteBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(addContent(_:)))
        favoriteBarButtonAtAccesoryView.tag = ContentType.favorite.rawValue
        
        let keyboardHideBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: keyboardHideImage, style: .plain, target: self, action: #selector(dismissKeyboard))
        
        
        var items = [UIBarButtonItem]()
        items.append(locationBarButtonAtAccesoryView)
        items.append(flexSpace)
        items.append(timeBarButtonAtAccesoryView)
        items.append(flexSpace)
        items.append(favoriteBarButtonAtAccesoryView)
        items.append(flexSpace)
        items.append(keyboardHideBarButtonAtAccesoryView)
        
        contentTypeToolbar.items = items
        contentTypeToolbar.sizeToFit()
        
        contentTextView.inputAccessoryView = contentTypeToolbar
    }
  
}


//, AVCaptureMetadataOutputObjectsDelegate, DTDeviceDelegate
extension AddContentViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // location Array의 마지막 좌표로 set
        if let lastLocatoin = locations.last {
            currentLocation = lastLocatoin
            reverseGeocodingRequestForSpecifiedLocation(location: currentLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dump(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            print("startUpdatingLocation called")
        } else if status == .denied {
            manager.stopUpdatingLocation()
            print("stopUpdatingLocation called")
        }
    }
    
    func reverseGeocodingRequestForSpecifiedLocation(location: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            
            if error != nil {
                print("Error + error.localizedDescription")
                return
            }
            
            if ((placemarks?.count) != nil) {
                
                let placemark = (placemarks?[0])! as CLPlacemark
                
                self.currentPlacemark = placemark
                self.displayLocationInfo(self.currentPlacemark!)
            }
        }
    }
    
    
    func displayLocationInfo(_ placemark: CLPlacemark){
        self.manager.stopUpdatingLocation()
        
        if let country = placemark.country, let administrativeArea = placemark.administrativeArea, let locality = placemark.locality, let subLocality = placemark.subLocality {
            
            address = "\(country) \(administrativeArea) \(locality) \(subLocality)"
            addressLabel.text = "\(country) \(administrativeArea) \(locality) \(subLocality)"
        }
        
    }
    
}


