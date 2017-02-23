//
//  DiaryContentDetailViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 16..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import MapKit



class DiaryContentDetailViewController: UIViewController, UITextViewDelegate, DataSentDelegate {
    
    
    var post: Post?
    var selectedIndexPath: IndexPath? // 홈화면에서 선택된 인덱스패스
    let showEditDiaryContentViewControllerSegueIdentifier = "showEditDiaryContentViewControllerSegue"
    
    
    @IBOutlet weak var createdDateLabel: UILabel! // 촬영 일시
    @IBOutlet weak var nicknameLabel: UILabel! // 유저 닉네임
    @IBOutlet weak var contentTextView: UITextView! // 작성된 글이 보여질 곳
    @IBOutlet weak var photoLocationMapView: MKMapView! // 사진의 위치를 지도로 보여주기 위함

    @IBOutlet weak var deletePostBarButton: UIBarButtonItem!
    
    
    var userNickname: String? // user 닉네임 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
    }
    
    // MARK: - ViewController Lifecycle override method
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryContentDetailViewController")
        
        // TabBar hidden
        tabBarController?.tabBar.isHidden = true
        
        if let post:Post = self.post {
            
            userNickname = FMDatabaseManager.shareManager().selectUserNickname(query: Statement.Select.nicknameOfUser, value: post.userIndex)
            if let userNickname = userNickname {
                nicknameLabel.text = userNickname
            }
            
            if let createdDate = post.createdDate {
                createdDateLabel.text = Date(timeIntervalSince1970: createdDate).toString()
            }
            
            if let content = post.content {
                contentTextView.text = content
            } else {
                contentTextView.text = "작성된 내용이 없습니다. Edit 버튼을 눌러 새로 작성해주세요."
            }
            
            if let latitude = post.latitude, let longitude = post.longitude {
                configureMapViewAtPhotoLocation(latitude: latitude, longitude: longitude)
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in DiaryContentDetailViewController")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in DiaryContentDetailViewController")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in DiaryContentDetailViewController")
        
    }
 
    
    // MARK: - Navigate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showEditDiaryContentViewControllerSegueIdentifier {
            if let editDiaryContentViewController:EditDiaryContentViewController = segue.destination as? EditDiaryContentViewController, let post = post {

                editDiaryContentViewController.post = post
                editDiaryContentViewController.delegate = self

            }
        }
        
    }
    
    
    
    // MARK: - UITextView delegate method
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    // MARK: - general Method
    
    // MARK:- update post (custom delegate)
    func setUpdateContentOfPost(data: String){
        self.contentTextView.text = data
        
    }
    
    
    // MARK: delete post

    @IBAction func deletePost(_ sender: Any) {
     
        guard let post = post else {
            print("delete post guard error")
            return
        }
        
        //ActionSheet형식으로 보여줄 UIAlertController 생성
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 삭제 버튼 생성과 액션 지정
        let deletePostAction: UIAlertAction = UIAlertAction(title: "삭제", style: .destructive, handler: {_ in self.deletePost(postIndex: post.postIndex, userIndex: post.userIndex)})
        
        
        //취소 버튼 생성과 취소 액션 지정
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel) { (action: UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        //addAction 부분
        alertController.addAction(deletePostAction)
        alertController.addAction(cancelAction)
        
        //ActionShee 호출
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func deletePost(postIndex : Int32, userIndex: Int32) {
        
        let imageFileName = FMDatabaseManager.shareManager().selectImageFilePath(query: Statement.Select.imageFilePath, value: [postIndex, userIndex])
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        //file Path 추가하여 생성
        
        let filePath = URL(fileURLWithPath: documentDirectoryPath)
        let filePathURL = filePath.appendingPathComponent(imageFileName)
        
        let fileManager = FileManager.default
        do {
            
            try fileManager.removeItem(atPath: filePathURL.path)
            let result = FMDatabaseManager.shareManager().deletePost(query: Statement.Delete.post, valuesOfColumns: [postIndex, userIndex])
            
            if result {
                navigationController?.popViewController(animated: true)
            }
        } catch let error {
            print("file delete error: ", error)
        }
    }
}

extension DiaryContentDetailViewController {
    func configureMapViewAtPhotoLocation(latitude : Float, longitude : Float) {
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = center
        annotaion.title = userNickname
        
        photoLocationMapView.addAnnotation(annotaion)
        self.photoLocationMapView.setRegion(region, animated: true)
    }
}
