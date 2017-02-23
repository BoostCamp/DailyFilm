//
//  PhotoAlbumCollectionViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 23..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

// UIImage와 pick, cancel 상태를 보내주는 델리게이트 프로토콜
protocol pickedImageSentDelegate {
    func setPickedImageFromPhotoAlbum(pickedImage: UIImage?, photoMode: AddPhotoMode)
}

private let reuseIdentifier = "ImageCell"

class PhotoAlbumCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var pickPhotoImageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var delegate: pickedImageSentDelegate? = nil
    
    var sizeOfImage:CGSize? // PrevieImageView의 CGSzie
    
    var assetsFetchResults: PHFetchResult<PHAsset>?
    var imageManger: PHCachingImageManager?
    var authorizationStatus: PHAuthorizationStatus?
    
    var currentSelectedIndex: Int? // Fetch Results의 인덱스, assets.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate, datasource set
        self.photoAlbumCollectionView.delegate = self
        self.photoAlbumCollectionView.dataSource = self
        
        
        //Init value
        pickPhotoImageBarButton.isEnabled = false


        // FloswLayout() 설정
        setFlowLayout()
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                self.imageManger = PHCachingImageManager()
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                
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
    
    
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func cancelPickImageFromPhotoAlbum(_ sender: Any) {
        self.delegate?.setPickedImageFromPhotoAlbum(pickedImage: nil, photoMode: .camera)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completePickImageFromPhotoAlbum(_ sender: Any) {
        
        guard let currentSelectedIndex = currentSelectedIndex, let sizeOfImage = sizeOfImage else {
            print("currentSelectedIndex error")
            return
        }
        
        let scale = UIScreen.main.scale
        let size = CGSize(width: sizeOfImage.width * scale, height: sizeOfImage.height * scale)

        let assets: PHAsset = self.assetsFetchResults![currentSelectedIndex]
        PHImageManager.default().requestImage(for: assets, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (result : UIImage?, info) in
            
            self.delegate?.setPickedImageFromPhotoAlbum(pickedImage: result, photoMode: .photoLibrary)
            self.dismiss(animated: true, completion: nil)

        })
        
    }
    
    @IBOutlet weak var completePickImageFromPhotoAlbum: UIBarButtonItem!
    
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

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.assetsFetchResults?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumItemCollectionViewCell
        
        // cell frame CGSize만큼 asset 을 설정하여 photoImageView에 set
        let asset: PHAsset = self.assetsFetchResults![indexPath.item]
        self.imageManger?.requestImage(for: asset, targetSize: cell.frame.size, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: {
            (result : UIImage?, info) in
            
            cell.photoImageView.image = result
            
            
        })
        
        return cell
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentSelectedIndex = indexPath.item
        pickPhotoImageBarButton.isEnabled = true
    }
}
