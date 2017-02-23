//
//  PhotoAlbumCollectionViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 23..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "ImageCell"

class PhotoAlbumCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    var assetsFetchResults: PHFetchResult<PHAsset>?
    var imageManger: PHCachingImageManager?
    var authorizationStatus: PHAuthorizationStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoAlbumCollectionView.delegate = self
        self.photoAlbumCollectionView.dataSource = self
        
        setFlowLayout()
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                self.imageManger = PHCachingImageManager()
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                self.assetsFetchResults = PHAsset.fetchAssets(with: options)
                
                self.photoAlbumCollectionView?.reloadData()
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

        
    }
    
    @IBAction func cancelPickImageFromPhotoAlbum(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    
    }
    
    
    func setFlowLayout() {
        let space:CGFloat = 3.0
        
        // the size of the main view, wihich is dependent upon screen size.
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        // 행 또는 열 내의 Item 사이의 공간을 제어합니다.
        collectionViewFlowLayout.minimumInteritemSpacing = space
        // 행 또는 열 사이의 공간을 제어합니다.
        collectionViewFlowLayout.minimumLineSpacing = space
        // cell(item) 사이즈를 제어합니다.
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return (self.assetsFetchResults?.count)!
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumItemCollectionViewCell
        

        let asset: PHAsset = self.assetsFetchResults![indexPath.item]
        self.imageManger?.requestImage(for: asset, targetSize: cell.frame.size, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: {
            (result : UIImage?, info) in
            
            cell.photoImageView.image = result

            
        })
        // Configure the cell
    
        return cell
    }

    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
