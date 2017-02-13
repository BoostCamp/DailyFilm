//
//  AddContentViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 13..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class AddContentViewController: UIViewController {
    
    
    @IBOutlet weak var previewOfPhotoToPostImageView: UIImageView!
    
    var takenResizedPhotoImage: UIImage?
    
    @IBOutlet weak var contentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // resize하여 view에 보여줌.
        previewOfPhotoToPostImageView.image = takenResizedPhotoImage?.resizeImage(targetSize: CGSize(width: 64, height: 64))
        
        // rightBarButton인 Done버튼 tint색을 애플의 파란색으로 변경
        navigationItem.rightBarButtonItem?.tintColor = UIColor.appleBlue()
        
        contentTextField.delegate = self
    }
    
    // MARK: View Controller Lifecycle
    
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
    
    @IBAction func completedPosting(_ sender: Any) {
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddContentViewController: UITextFieldDelegate {
    
    enum ContentType: Int {
        case location = 0
        case time
        case favorite
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        if contentTextField.inputAccessoryView == nil {
            addContentTypeButtonOnKeyboard()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("textFieldShouldClear")
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        // Enter was pressed
        dismissKeyboard()
        //        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    
    // MARK: keyboard control function
    
    
    func keyboardWillShow(_ notification:Notification){
        // 아래 TextField에서 입력 시에, 키보드 높이만큼 view 의 offset을 move
        if contentTextField.isFirstResponder {
            
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        // keyboard가 hide될 때, view 의 offset을 복귀
        // 0으로 해도 결과는 같으나, 아래 TextField 입력 할때 오프셋을 변경했으니 조건 추가.
        if contentTextField.isFirstResponder{
            view.frame.origin.y = 0
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
        contentTextField.resignFirstResponder()
    }
    
    func addContent(to type: UIBarButtonItem){
        dump(type.tag)
        
        switch type.tag {
        case ContentType.location.rawValue :
            print("촬영 위치")
        case ContentType.time.rawValue :
            print("게시 시간")
            
            // Date 생성
            let date:Date = Date()
            
            //Calendar Component에 맞게 Date 변환
            let now:Date = date.getDateComponents()
            
            // 현재 시간 기준으로 timeIntervalSince1970 추출
            let timeIntervalOfNow:TimeInterval = now.timeIntervalSince1970
            
            //timeIntervla format으로 현재 date 추출
            let currentDateInTimeIntervalFormat = Date(timeIntervalSince1970: timeIntervalOfNow)
            
            contentTextField.text = currentDateInTimeIntervalFormat.toString()
            
        case ContentType.favorite.rawValue :
            print("위시리스트 설정 여부")
        default:
            return
        }
        
    }
    
    func addContentTypeButtonOnKeyboard() {
        
        let screenWidthSize:CGFloat = UIScreen.main.bounds.width
        
        let locationImage: UIImage? = UIImage(named: "location")
        let timeImage: UIImage? = UIImage(named: "time")
        let favoriteImage: UIImage? = UIImage(named: "favorite")
        
        let contentTypeToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidthSize, height: 44))
        contentTypeToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let locationBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: locationImage, style: .plain, target: self, action: #selector(addContent(to:)))
        locationBarButtonAtAccesoryView.tag = ContentType.location.rawValue
        
        let timeBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: timeImage, style: .plain, target: self, action: #selector(addContent(to:)))
        timeBarButtonAtAccesoryView.tag = ContentType.time.rawValue
        
        let favoriteBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(addContent(to:)))
        favoriteBarButtonAtAccesoryView.tag = ContentType.favorite.rawValue
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(locationBarButtonAtAccesoryView)
        items.append(flexSpace)
        items.append(timeBarButtonAtAccesoryView)
        items.append(flexSpace)
        items.append(favoriteBarButtonAtAccesoryView)
        items.append(flexSpace)
        
        contentTypeToolbar.items = items
        contentTypeToolbar.sizeToFit()
        
        contentTextField.inputAccessoryView = contentTypeToolbar
    }
}
