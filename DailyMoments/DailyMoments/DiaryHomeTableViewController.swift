//
//  DiaryHomeTableViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

class DiaryHomeTableViewController: UITableViewController, ContentLabelDelegate {
    
     fileprivate static let showDiaryContentDetailViewControllerSegueIdentifier = "showDiaryContentDetailViewController"
    
    
    var authorizationStatus: PHAuthorizationStatus? // // Photo 접근 권한을 위한 저장 프로퍼티
    var posts: [Post]? // post 개수
    var userIndex: Int32? // userIndex
    var createdDate: TimeInterval? // 생성 시간
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
//        tableView.allowsSelection = false
        
        FMDatabaseManager.shareManager().openDatabase(databaseName: DatabaseConstant.databaseName)
    }
    
    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryHomeViewController")
        
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                print(authorizationStatusOfPhoto)
            case .denied:
                print(authorizationStatusOfPhoto)
            case .notDetermined:
                print(authorizationStatusOfPhoto)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print(authorizationStatusOfPhoto)
            }
        }
        
        
        // Date 생성
        let date:Date = Date()
        
        //Calendar Component에 맞게 Date 변환
        let now:Date = date.getDateComponents()
        
        // 현재 시간 기준으로 timeIntervalSince1970 추출
        let timeIntervalOfNow:TimeInterval = now.timeIntervalSince1970
        
        let userProfile: UserProfile = UserProfile(userIndex: 0, userId: "nso502354@gmail.com", userPassword: "1234", userNickname: "namsang", createdDate: timeIntervalOfNow )
        
        let successFlag = FMDatabaseManager.shareManager().insert(query: Statement.Insert.userProfile, valuesOfColumns: [userProfile.userId as Any, userProfile.userPassword as Any, userProfile.userNickname as Any, userProfile.createdDate as Any])
        
        let userProfiles: [UserProfile] = FMDatabaseManager.shareManager().selectUserProfile(query: Statement.Select.userProfile, value: "nso502354@gamil.com")
        
        userIndex = userProfiles[0].userIndex
        if let userIndex = userIndex {
            posts = FMDatabaseManager.shareManager().selectPosts(query: Statement.Select.post, value : userIndex)
        }
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in DiaryHomeViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in DiaryHomeViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in DiaryHomeViewController")
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        print("prepare")
        if segue.identifier == DiaryHomeTableViewController.showDiaryContentDetailViewControllerSegueIdentifier {
            if let diaryContentDetailViewController:DiaryContentDetailViewController = segue.destination as? DiaryContentDetailViewController {
                
                diaryContentDetailViewController.userIndex = userIndex
                diaryContentDetailViewController.createdDate = createdDate
                
            }
        }
        
        
        
     }
    
    
}



/*
 
 if let addTextViewController:AddContentViewController = segue.destination as? AddContentViewController {
 self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
 addTextViewController.edidtedPhotoImage = photographedImage.image
 }

 
 */


extension DiaryHomeTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (posts?.count)!
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConstants.diary, for: indexPath) as! HomeDiaryTableViewCell
        
        
        
        // for using ContentLabelDelegate
        cell.delegate = self
        
        
        if let post = posts?[indexPath.row] {
            if let address = post.address, let imageFilePath = post.imageFilePath, let content = post.content, let createdDate = post.createdDate {
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                //file Path 추가하여 생성
                let documentDirectoryPathURL = URL(fileURLWithPath: documentDirectoryPath)
                
                let editedImageURL = documentDirectoryPathURL.appendingPathComponent(imageFilePath)
                
                let fixedOrientationimage:UIImage? = UIImage(contentsOfFile: editedImageURL.path)
                
                if let image = fixedOrientationimage {
                    
                    cell.userIdLabel?.text = "nso502354@gmail.com"
                    cell.locationLabel.text = address
                    cell.photoImageView?.image = image.cropToSquareImage()
                    cell.contentLabel.text = content
                    
                    cell.createdDate.text = Date(timeIntervalSince1970: createdDate).toString()
                    
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenBounds = UIScreen.main.bounds
        return screenBounds.width * 1.5
    }
    
    
    func showDetailContent(sender: HomeDiaryTableViewCell){
        print("showDetailContent")
        let cell:HomeDiaryTableViewCell = sender as HomeDiaryTableViewCell
        let date = cell.createdDate.text?.convertStringToDate()
        createdDate = date?.timeIntervalSince1970
        dump(createdDate)

        performSegue(withIdentifier: DiaryHomeTableViewController.showDiaryContentDetailViewControllerSegueIdentifier, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = posts?[indexPath.row] {
            dump(post)
            
        }
    }
    
}
