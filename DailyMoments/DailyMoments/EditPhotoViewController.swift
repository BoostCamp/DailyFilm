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
    
    var takenPhotoImage: UIImage? // 촬영한 원본 Image
    var takenResizedPhotoImage: UIImage? // 촬영한 Image를 reszie
    var imageTapStatus: Bool? // 이미지 탭 여부

    fileprivate static let showAddContentViewControllerSegueIdentifier = "showAddContentViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UICollectionViewDelegate & UICollecionViewDatasource
        imagefilterCollectionView.delegate = self
        imagefilterCollectionView.dataSource = self
        
        // 촬영한 이미지를 .right 방향에서 .up 방향으로 set
        takenPhotoImage = fixOrientationOfImage(image: takenPhotoImage!)
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

        // toolbar hide
        navigationController?.isToolbarHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear in EditPhotoViewController")
        
        // 콜렉션 뷰의 첫번째 Cell을 선택함.
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
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == EditPhotoViewController.showAddContentViewControllerSegueIdentifier {
            if let addTextViewController:AddContentViewController = segue.destination as? AddContentViewController {
                addTextViewController.edidtedPhotoImage = photographedImage.image
            }
            
        }
        
    }
 
      
}


extension EditPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    fileprivate static let cameraFilterCollectionViewCellIdentifier: String = "FilterCell"
    
    struct PhotoEditorTypes{
        
        static let titles: [String?] = ["Filter"]
        
        // filter input Key
        static let rowTitles: [[String?]?] =
            [["Normal",
              "CIPhotoEffectMono",
              "CIPhotoEffectTonal",
              "CIPhotoEffectNoir",
              "CIPhotoEffectFade",
              "CIPhotoEffectChrome",
              "CIPhotoEffectProcess",
              "CIPhotoEffectTransfer",
              "CIPhotoEffectTransfer"]]
        
        // filter 이름
        static let rowTitlesValues: [[String?]?] =
            [["Normal",
              "Mono",
              "Tonal",
              "Noir",
              "Fade",
              "Chrome",
              "Process",
              "Transfer",
              "Instant"]]
        
        static func numberOfRows(of section: Int) -> Int {
            return rowTitles[section]?.count ?? 0
        }
        static func titleForIndexPath(_ indexPath: IndexPath) -> String? {
            return rowTitles[indexPath.section]?[indexPath.row]
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections")
        return PhotoEditorTypes.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection")
        return PhotoEditorTypes.numberOfRows(of: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditPhotoViewController.cameraFilterCollectionViewCellIdentifier, for: indexPath) as! CameraFillterCollectionViewCell
        
        cell.filterTitleLabel.text = PhotoEditorTypes.rowTitlesValues[indexPath.section]?[indexPath.row]
             
        if let filterTitle = PhotoEditorTypes.rowTitles[indexPath.section]?[indexPath.row] {
            cell.filterImageView.image = takenResizedPhotoImage?.applyFilter(type: filterTitle)
                
        }
        
        return cell
    }
    
    
    // cell 선택했을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            selectedCell.isSelected = true
            
            if let filterTitle = PhotoEditorTypes.rowTitles[indexPath.section]?[indexPath.row] {
                
                DispatchQueue.main.async {
                    self.photographedImage.image = self.takenPhotoImage?.applyFilter(type: filterTitle)
                }
            }
            
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
            imagefilterCollectionView.isHidden = true
        } else {
            navigationController?.isNavigationBarHidden = false
            imagefilterCollectionView.isHidden = false
        }
    }
    
    func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
            
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    

}

