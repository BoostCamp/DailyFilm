//
//  DiaryContentDetailViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 16..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import MapKit

class DiaryContentDetailViewController: UIViewController {
    
    
    var post: Post?
    
    @IBOutlet weak var createdDateLabel: UILabel! // 촬영 일시
    @IBOutlet weak var nicknameLabel: UILabel! // 유저 닉네임
    @IBOutlet weak var contentTextView: UITextView! // 작성된 글이 보여질 곳
    @IBOutlet weak var photoLocationMapView: MKMapView! // 사진의 위치를 지도로 보여주기 위함
    
    var userNickname: String? // user 닉네임 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - ViewController Lifecycle override method
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryContentDetailViewController")
        
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
