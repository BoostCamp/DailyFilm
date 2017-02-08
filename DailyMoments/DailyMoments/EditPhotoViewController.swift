//
//  EditPhotoViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 8..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class EditPhotoViewController: UIViewController {
   
    let cameraFilterCollectionViewCellIdentifier: String = "FilterCell"
    
    struct PhotoEditorTypes{
        
        static let titles: [String?] = ["Filter"]
        static let rowTitles: [[String?]?] = [["Normal", "Mono", "Tonal", "Noir", "Fade", "Chrome", "Process", "Transfer", "Instant"]]

        static func numberOfRows(of section: Int) -> Int {
            return rowTitles[section]?.count ?? 0
        }
        static func titleForIndexPath(_ indexPath: IndexPath) -> String? {
            return rowTitles[indexPath.section]?[indexPath.row]
        }
    }
    
    @IBOutlet weak var imagefilterCollectionView: UICollectionView!
    @IBOutlet weak var photographedImage: UIImageView!
    var takenPhotoImage: UIImage?
    var takenResizedPhotoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagefilterCollectionView.delegate = self
        imagefilterCollectionView.dataSource = self
        photographedImage.image = takenPhotoImage
    }

    
    // MARK:- View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in EditPhotoViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in EditPhotoViewController")
               
        self.imagefilterCollectionView.selectItem(at: IndexPath.init(item: 0, section: 0), animated: true, scrollPosition: .bottom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in EditPhotoViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in EditPhotoViewController")
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


extension EditPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate{
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections")
        return PhotoEditorTypes.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection")
        return PhotoEditorTypes.numberOfRows(of: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraFilterCollectionViewCellIdentifier, for: indexPath) as! CameraFillterCollectionViewCell
        
        cell.filterTitleLabel.text = PhotoEditorTypes.rowTitles[indexPath.section]?[indexPath.row]
        cell.filterImageView.image = takenResizedPhotoImage
        return cell
    }
    
    
    // cell 선택했을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            selectedCell.isSelected = true
            
            // 선택한 셀을 수평 중간으로 스크롤링 해주는 메소드
            self.imagefilterCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    // cell 선택이 풀렸을 때 호출
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let deselectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            deselectedCell.isSelected = false
        }
    }
}

