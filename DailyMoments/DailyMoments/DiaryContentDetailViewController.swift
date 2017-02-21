//
//  DiaryContentDetailViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 16..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class DiaryContentDetailViewController: UIViewController {

    
    var post: Post?

    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        if let post:Post = self.post {
            
            var text: String = ""
 
            
            let userNickname:String? = FMDatabaseManager.shareManager().selectUserNickname(query: Statement.Select.nicknameOfUser, value: post.userIndex)
            if let userNickname = userNickname {
                nicknameLabel.text = userNickname
            }
            
            if let createdDate = post.createdDate {
                
                createdDateLabel.text = Date(timeIntervalSince1970: createdDate).toString()
            }
           
            
            if let content = post.content {
                contentTextView.text = content
            }
            
            if let isFavorite = post.isFavorite {
                text += "\(isFavorite)"
            }
            
            if let latitude = post.latitude {
                text += "\(latitude)"
            }
            
            if let longitude = post.longitude {
                text += "\(longitude)"
            }
            
            if let address = post.address {
                text += address
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
