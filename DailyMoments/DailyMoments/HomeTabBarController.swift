//
//  HomeTabBarController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 7..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class HomeTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let index = tabBarController.viewControllers?.index(of: viewController) else {
            
            return true
        }
        
        if index == ViewControllerIndex.cameraView {
            
            self.performSegue(withIdentifier: HomeTabBarController.showCameraSegueIdentifier, sender: self)
            
            return false
        }
        return true
    }
    
    
  
    // MARK:- Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
  
        
        
        /*
         
         
         if segue.identifier == EditPhotoViewController.showAddContentViewControllerSegueIdentifier {
         if let addTextViewController:AddContentViewController = segue.destination as? AddContentViewController {
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
         addTextViewController.edidtedPhotoImage = editedTakenPhotoImage
         
         }
         }

         
         */
    }
 
    
}

// MARK:- Extension for constants

extension HomeTabBarController {
    
    fileprivate struct ViewControllerIndex {
        static let main = 0
        static let cameraView = 1
        static let account = 2
    }
    
    fileprivate static let showCameraSegueIdentifier = "showCameraView"
    
}


// MARK:- Extension for Type methods

extension HomeTabBarController {
    static func someTypeMethod() {
        
    }
}

