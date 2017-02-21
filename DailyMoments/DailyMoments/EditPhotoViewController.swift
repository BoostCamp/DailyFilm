//
//  EditPhotoViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 8..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos

class EditPhotoViewController: UIViewController {
    
    @IBOutlet weak var imagefilterCollectionView: UICollectionView!
    
    @IBOutlet weak var photographedImage: UIImageView!
    
    var takenPhotoImage: UIImage? // 촬영한 이미지(원본 or 필터 적용)
    var originalPhotoImage: UIImage? // 촬영한 원본 이미지
    var selectedFilterIndex: Int? // 촬영 시에 선택한 필터에 해당하는 인덱스
    var takenResizedPhotoImage: UIImage? // 촬영한 Image를 reszie
    var imageTapStatus: Bool? // 이미지 탭 여부
    
    fileprivate static let showAddContentViewControllerSegueIdentifier = "showAddContentViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UICollectionViewDelegate & UICollecionViewDatasource
        imagefilterCollectionView.delegate = self
        imagefilterCollectionView.dataSource = self
        
        photographedImage.image = takenPhotoImage
        
        // 이미지가 안눌린 상태로 초기값 설정
        imageTapStatus = false
        
        // 이미지에서 Tap Gesture 받을 수 있게 설정 (기본값은 false)
        photographedImage.isUserInteractionEnabled = true
        
        
        
        let photographedImageGestureRecogninzer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageForFullView))
        photographedImage.addGestureRecognizer(photographedImageGestureRecogninzer)
    }
    
    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in EditPhotoViewController")
        
        // toolbar show
        navigationController?.isToolbarHidden = false
        
        // navigationBar show
        navigationController?.navigationBar.isHidden = false

        // 콜렉션 뷰의 첫번째 Cell을 선택함.
        if let selectedFilterIndex = selectedFilterIndex {
          
            DispatchQueue.main.async {
            
                // 선택된 필터 인덱스에 해당하는 필터 셀 선택
                self.imagefilterCollectionView.selectItem(at: IndexPath.init(item: selectedFilterIndex, section: 0), animated: true, scrollPosition: .bottom)
                
                // 선택된 필터 인덱스에 해당하는 필터 셀 위치로 scroll
                self.imagefilterCollectionView.scrollToItem(at: IndexPath.init(item: selectedFilterIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in EditPhotoViewController")
        
        // 네비게이션 컨트롤러에서 스와이프로 뒤로 가는 제스처를 disabled, 콜렉션 뷰 스크롤 gesture와의 이슈를 위함.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear in EditPhotoViewController")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear in EditPhotoViewController")
    }
    
    
    // MARK: - Toolbar IBAction
    
    @IBAction func imageEditAction(_ sender: Any) {
        if let editImageBarButton: UIBarButtonItem = sender as? UIBarButtonItem {
            
            switch editImageBarButton.tag {
            case 0:
                print("filter")
                
            case 1:
                print("rotate image")
                
            default:
                return
            }
            
        }
        
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == EditPhotoViewController.showAddContentViewControllerSegueIdentifier {
            if let addTextViewController:AddContentViewController = segue.destination as? AddContentViewController {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                addTextViewController.edidtedPhotoImage = photographedImage.image
            }
        }
    }
}


extension EditPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections")
        return PhotoEditorTypes.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection")
        return PhotoEditorTypes.numberOfFilterType()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraFilterCollectionViewCellIdentifier, for: indexPath) as! CameraFillterCollectionViewCell
        
        
        let displayFilterName =  PhotoEditorTypes.titleForIndexPath(indexPath).replacingOccurrences(of: "CIPhotoEffect", with: "")
        
        cell.filterTitleLabel.text = displayFilterName
        
        let filterTitle = PhotoEditorTypes.titleForIndexPath(indexPath)
        cell.filterImageView.image = takenResizedPhotoImage?.applyFilter(type: filterTitle)
        
        return cell
    }
    
    
    // cell 선택했을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            selectedCell.isSelected = true
            
            let filterTitle = PhotoEditorTypes.titleForIndexPath(indexPath)
            
            self.photographedImage.image = self.originalPhotoImage?.applyFilter(type: filterTitle)
            
            // 선택한 셀을 수평 중간으로 스크롤링 해주는 메소드
            DispatchQueue.main.async {
                self.imagefilterCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
        }
    }
    
    // cell 선택이 풀렸을 때 호출
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let deselectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            deselectedCell.isSelected = false
        }
    }
}

extension EditPhotoViewController {
    
    func imageForFullView(sender: UITapGestureRecognizer){
        if let status = imageTapStatus {
            
            let tap = sender.tapStatus(status)
            switch tap {
            case true:
                self.imageTapStatus = tap
                changeUIToState(true)
            case false:
                self.imageTapStatus = tap
                changeUIToState(false)
            }
        }
    }
    
    func changeUIToState(_ tap : Bool){
        
        // NavigationBar와 하단의 CollectionView를 show/hide
        if tap {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isToolbarHidden = true
            imagefilterCollectionView.isHidden = true
            photographedImage.backgroundColor = .black
        } else {
            navigationController?.isNavigationBarHidden = false
            navigationController?.isToolbarHidden = false
            imagefilterCollectionView.isHidden = false
            photographedImage.backgroundColor = .clear
        }
    }
}

