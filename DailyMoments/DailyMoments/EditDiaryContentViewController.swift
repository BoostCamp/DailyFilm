//
//  EditDiaryContentViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 22..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

// 컨텐츠의 수정 사항을 저장하고 수정 내용을 보내주기 위한 프로토콜
protocol DataSentDelegate {
    func setUpdateContentOfPost(title: String, content: String)
}


class EditDiaryContentViewController: UIViewController {
    
    
    var post: Post?
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var delegate: DataSentDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        if let post = post {
            if let  title = post.title, let content = post.content {
                titleTextView.text = title
                contentTextView.text = content
            }
        }
        
        
        contentTextView.delegate = self
        titleTextView.delegate = self
    }
    
    
    
    @IBAction func tappedEditedContentSave(_ sender: Any) {
        
        if let newTitle = titleTextView.text, let newContent = contentTextView.text {
            updateContentOfPost(title: newTitle, content: newContent, completion: { (success:Bool) in
                
                if success {
                    self.dismissKeyboard()
                    
                    self.dismiss(animated: true, completion: { 
                        self.delegate?.setUpdateContentOfPost(title: newTitle, content: newContent)
                    })
                    

                } else {
                    // 실패시
                    print("update content of post fail.")
                }
                
            })
        }
    }
    
    func updateContentOfPost(title newTitle: String, content newContent: String, completion: ((_ success:Bool) -> Void)?) {
        let successFlag = FMDatabaseManager.shareManager().updatePostContent(query: Statement.Update.contentOfPost, valuesOfColumns: [newTitle as Any, newContent as Any, post?.postIndex as Any, post?.userIndex as Any])
        
        // 성공 여부에 따른 completion Handler
        completion?(successFlag)
        
    }
    
    
    
    
    @IBAction func tappedEditContentCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}

extension EditDiaryContentViewController: UITextViewDelegate {
    
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
        
        let keyboardHideImage: UIImage? = UIImage(named: "keyboard_hide")
        
        let contentTypeToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidthSize, height: 44))
        contentTypeToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        let keyboardHideBarButtonAtAccesoryView: UIBarButtonItem = UIBarButtonItem(image: keyboardHideImage, style: .plain, target: self, action: #selector(dismissKeyboard))
        
        
        var items = [UIBarButtonItem]()
        
        items.append(flexSpace)
        items.append(keyboardHideBarButtonAtAccesoryView)
        
        contentTypeToolbar.items = items
        contentTypeToolbar.sizeToFit()
        
        titleTextView.inputAccessoryView = contentTypeToolbar
        contentTextView.inputAccessoryView = contentTypeToolbar
    }
    
}

