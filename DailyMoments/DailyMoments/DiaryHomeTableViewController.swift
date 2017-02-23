//
//  DiaryHomeTableViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 9..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

class DiaryHomeTableViewController: UITableViewController {
    
    var authorizationStatus: PHAuthorizationStatus? // // Photo 접근 권한을 위한 저장 프로퍼티
    var posts: [Post]? // post Array
    var userIndex: Int32? // userIndex
    var createdDate: TimeInterval? // 생성 시간
    var postCount: Int? //post 개수
    var selectedIndex: IndexPath? // 선택한 셀 인덱스를 저장할 변수
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        
        FMDatabaseManager.shareManager().openDatabase(databaseName: DatabaseConstant.databaseName)
        
        // userIndex를 return
        userIndex = FMDatabaseManager.shareManager().selectUserIndexFromUserId(query: Statement.Select.userIndexOfUser, value: UserProfileConstants.id)
        
        guard let userIndex = userIndex else {
            fatalError()
        }
        
        // user가 올린 포스트의 개수만 return
        postCount = FMDatabaseManager.shareManager().selectSpecificUserPost(query: Statement.Select.postCountOfUser, value: userIndex)
    }
    
    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryHomeViewController")
        // status bar show
        UIApplication.shared.isStatusBarHidden = false
        
        tabBarController?.tabBar.isHidden = false
        
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
        
        let userProfile: UserProfile = UserProfile(userIndex: 0, userId: UserProfileConstants.id, userPassword: UserProfileConstants.password, userNickname: UserProfileConstants.nickname, createdDate: timeIntervalOfNow )
        
        let isUserIdDuplicated = FMDatabaseManager.shareManager().duplicatedCheckOfUserProfile(query: Statement.Select.duplicatedCheckOfUserProfile, value: userProfile.userId!)

        // 중복되지 않았으면(false) USER_PROFILE 테이블에 추가
        if isUserIdDuplicated == false {
            
            let successFlag = FMDatabaseManager.shareManager().insert(query: Statement.Insert.userProfile, valuesOfColumns: [userProfile.userId as Any, userProfile.userPassword as Any, userProfile.userNickname as Any, userProfile.createdDate as Any])
            
            
        }
        let userProfiles: [UserProfile] = FMDatabaseManager.shareManager().selectUserProfile(query: Statement.Select.userProfile, value: "nso502354@gamil.com")
        
        userIndex = userProfiles[0].userIndex
        if let userIndex = userIndex {
            
            posts = FMDatabaseManager.shareManager().selectPosts(query: Statement.Select.post, value : userIndex)
            
            if postCount == posts?.count {
                // insert, delete가 아닌 경우
                print("// insert, delete가 아닌 경우")
                selectedIndex = nil
                tableView.reloadData()
                
            } else if postCount != posts?.count {
                
                if let selectedIndex = selectedIndex {
                    print("// delete post - POST Table에 delete 되었고, 선택한 셀 index가 있을 때")
                    // delete post - POST Table에 delete 되었고, 선택한 셀 index가 있을 때
                    postCount = posts?.count
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [selectedIndex], with: .none)
                    tableView.endUpdates()
                    
                    
                } else {
                    print("// insert post - POST Table에 insert 되었고, 선택한 셀 index가 nil일때")
                    // insert post - POST Table에 insert 되었고, 선택한 셀 index가 nil일때
                    postCount = posts?.count
                    tableView.reloadData()
                    /*
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                    tableView.endUpdates()
                    */
                }
            } else {
                print("nothing...")
            }
        }
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
        
        if segue.identifier == DiaryPhotoTableViewConstants.showDiaryContentDetailViewControllerSegueIdentifier, let index = tableView.indexPathsForSelectedRows?.first {
            tableView.deselectRow(at: index, animated: true)
            
            if let diaryContentDetailViewController:DiaryContentDetailViewController = segue.destination as? DiaryContentDetailViewController {
                
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                
                diaryContentDetailViewController.post = posts?[index.row]
                self.selectedIndex = index
                diaryContentDetailViewController.selectedIndexPath = index
                
            }
        }
    }
}


// MARK: - TableView delegate extension
extension DiaryHomeTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postCount!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryPhotoTableViewConstants.cellIdentifier, for: indexPath) as! DiaryPhotoTableViewCell
        
        
        if let post = posts?[indexPath.row]  {
            
            cell.profileImageView.image = UIImage(named: "person")
            
            let userNickname:String? = FMDatabaseManager.shareManager().selectUserNickname(query: Statement.Select.nicknameOfUser, value: post.userIndex)
            if let userNickname = userNickname {
                cell.userNicknameLabel.text = userNickname
            }
            
            if let address = post.address, let imageFilePath = post.imageFilePath, let content = post.content, let createdDate = post.createdDate {
                
                cell.addressLabel.text = address
                
                // Create a DocumentDirectoryPath
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                
                // URL of DocumentDirectoryPath
                let documentDirectoryPathURL = URL(fileURLWithPath: documentDirectoryPath)
                
                // file URL of DocumentDirectoryPath
                let editedImageURL = documentDirectoryPathURL.appendingPathComponent(imageFilePath)
                
                let getImageFromDocuments: UIImage? = UIImage(contentsOfFile: editedImageURL.path)
                
                if let image = getImageFromDocuments {

                    DispatchQueue.main.async {
                        cell.photoImageView?.image = image.cropToSquareImage()
                    }
                }
                
                cell.contentLabel.text = content
                cell.createdDateLabel.text = Date(timeIntervalSince1970: createdDate).toString()
                
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DiaryPhotoTableViewConstants.showDiaryContentDetailViewControllerSegueIdentifier, sender: nil)
    }
    
}
