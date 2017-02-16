//
//  DiaryContentDetailViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 16..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class DiaryContentDetailViewController: UIViewController {

    
    
    /* -----
 
     userIndex와 createdDate로 post내용을 select합니다.
     
    ----- */
    var userIndex: Int32? // userIndex와
    var createdDate: TimeInterval?
    
    
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        static let postById = "SELECT image_file_path, content, is_favorite, address, latitude, longitude FROM WHERE user_index = ? and created_date = ?;"

  
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let post:Post = FMDatabaseManager.shareManager().selectSpecificUserPostAtCreatedDate(query: Statement.Select.postById, value: userIndex as Any, createdDate as Any) {
            
            contentTextView.text = "\(post.imageFilePath)" + "\(post.content)" + "\(post.isFavorite)" + "\(post.latitude)" + "\(post.longitude)" + "\(post.address)"
            
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
