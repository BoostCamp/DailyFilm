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
    
    var authorizationStatus: PHAuthorizationStatus? // // Photo 접근 권한을 위한 저장 프로퍼티
    var posts: [Post]? // post Array
    var userIndex: Int32? // userIndex
    var createdDate: TimeInterval? // 생성 시간
    var postCount: Int? //post 개수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        
        FMDatabaseManager.shareManager().openDatabase(databaseName: DatabaseConstant.databaseName)
   
        userIndex = FMDatabaseManager.shareManager().selectUserIndexFromUserId(query: Statement.Select.userIndexOfUser, value: UserProfileConstants.id)
        
        guard let userIndex = userIndex else {
            fatalError()
        }
        postCount = FMDatabaseManager.shareManager().selectSpecificUserPost(query: Statement.Select.postCountOfUser, value: userIndex)
    }
    
    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in DiaryHomeViewController")
        
        UIApplication.shared.isStatusBarHidden = false // status bar show

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
        
        let successFlag = FMDatabaseManager.shareManager().insert(query: Statement.Insert.userProfile, valuesOfColumns: [userProfile.userId as Any, userProfile.userPassword as Any, userProfile.userNickname as Any, userProfile.createdDate as Any])
        
        let userProfiles: [UserProfile] = FMDatabaseManager.shareManager().selectUserProfile(query: Statement.Select.userProfile, value: "nso502354@gamil.com")
        
        userIndex = userProfiles[0].userIndex
        if let userIndex = userIndex {
            posts = FMDatabaseManager.shareManager().selectPosts(query: Statement.Select.post, value : userIndex)
            postCount = posts?.count
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
        if segue.identifier == DiaryPhotoTableViewConstants.showDiaryContentDetailViewControllerSegueIdentifier {
            if let diaryContentDetailViewController:DiaryContentDetailViewController = segue.destination as? DiaryContentDetailViewController {
                
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                diaryContentDetailViewController.userIndex = userIndex
                diaryContentDetailViewController.createdDate = createdDate
                
            }
        }
    }
}


extension DiaryHomeTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return DiaryPhotoTableViewConstants.numberOfRows()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {

//        return (posts?.count)!
        return postCount!
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryPhotoTableViewConstants.cellIdentifier(for: indexPath), for: indexPath)
        
        guard let post = posts?[indexPath.section] else {
            fatalError()
        }
        
        
        if let cell = cell as? DiaryPhotoTableViewCell {
        
            if indexPath.row == 0{
         
                if let imageFilePath = post.imageFilePath {
                    
                    // Create a DocumentDirectoryPath
                    let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                   
                    // URL of DocumentDirectoryPath
                    let documentDirectoryPathURL = URL(fileURLWithPath: documentDirectoryPath)
                    
                    // file URL of DocumentDirectoryPath
                    let editedImageURL = documentDirectoryPathURL.appendingPathComponent(imageFilePath)
                    
                    let fixedOrientationimage: UIImage? = UIImage(contentsOfFile: editedImageURL.path)
                    
                    if let image = fixedOrientationimage {
                        cell.photoImageView?.image = image.cropToSquareImage()
                    }
                }
                
            }
        } else if let cell = cell as? DiaryContentTableViewCell {
        
            if indexPath.row == 1{
                
                if let content = post.content, let createdDate = post.createdDate {
                    // for using ContentLabelDelegate
                    cell.delegate = self
                    cell.contentLabel.text = content
                    cell.createdDate.text = Date(timeIntervalSince1970: createdDate).toString()
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight: CGFloat = 0
        let screenBounds = UIScreen.main.bounds
        
        if indexPath.row == 0 {
            cellHeight = screenBounds.width
        } else if indexPath.row == 1 {
            cellHeight = screenBounds.width / 4
        }
        
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let headerHieght =  screenHeight / 10
        let profileImageSize = screenWidth / 12
        let intervalSize = (headerHieght - profileImageSize) / 2
        guard let post = posts?[section] else {
            return UIView()
            
        }
        
        let view = UIView()
        
        
        let profileImageView: UIImageView = UIImageView(image: UIImage(named: "person"))
        profileImageView.frame = CGRect(x: intervalSize, y: intervalSize, width: profileImageSize, height: profileImageSize)
        profileImageView.contentMode = .scaleAspectFill
        view.addSubview(profileImageView)
        
        
        
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.frame = CGRect(x: profileImageSize + (intervalSize * 2), y: (intervalSize / 2) , width: screenWidth - profileImageSize, height: headerHieght - intervalSize)
        
        let userIdLabel: UILabel = UILabel()
        
        userIdLabel.sizeToFit()
        userIdLabel.text = String(describing: post.userIndex)
        userIdLabel.font = UIFont(name: userIdLabel.font.fontName, size: 14)
        
        let addressLabel: UILabel = UILabel()
        addressLabel.sizeToFit()
        
        if let address = post.address {
            addressLabel.text = address
            addressLabel.textColor = UIColor.darkGray
            addressLabel.font = UIFont(name: addressLabel.font.fontName, size: 12)
        }
        
        
        stackView.addArrangedSubview(userIdLabel)
        stackView.addArrangedSubview(addressLabel)
        
        view.addSubview(stackView)
        
        return view
    }
    
    override func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let screenHeightSize = UIScreen.main.bounds.height
        
        return screenHeightSize / 10
    }
    
    func showDetailContent(sender: DiaryContentTableViewCell){
        let cell:DiaryContentTableViewCell = sender as DiaryContentTableViewCell
        let date = cell.createdDate.text?.convertStringToDate()
        createdDate = date?.timeIntervalSince1970
        
        performSegue(withIdentifier: DiaryPhotoTableViewConstants.showDiaryContentDetailViewControllerSegueIdentifier, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = posts?[indexPath.row] {
            
        }
    }
    
}
