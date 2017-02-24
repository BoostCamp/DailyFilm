//
//  EditPhotoViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 8..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit
import Photos
import CoreGraphics
import CoreImage


class EditPhotoViewController: UIViewController {
    
    @IBOutlet weak var imagefilterCollectionView: UICollectionView!
    
    @IBOutlet weak var editImageEffectToolbar: UIToolbar!
    @IBOutlet weak var photographedImage: UIImageView!
    
    
    
    var cameraRelatedCoreImageResource: CameraRelatedCoreImageResource?
    
    var previewPhotoImage: UIImage?
    
    var originalPhotoImage: UIImage? // 촬영한 원본 이미지
    var selectedFilterIndex: Int? // 촬영 시에 선택한 필터에 해당하는 인덱스
    var transform: CGAffineTransform? // 이미지 회전 정보
    
    var openGLContext: EAGLContext? // CGImage를 위한 프로퍼티
    var ciContext: CIContext? // CIImage를 위한 프로퍼티
    var editedCIImage: CIImage?
    var editedCGImage: CGImage?
    
    
    var imageTapStatus: Bool? // 이미지 탭 여부
    
    fileprivate static let showAddContentViewControllerSegueIdentifier = "showAddContentViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad in EditPhotoView")
        
        // Set UICollectionViewDelegate & UICollecionViewDatasource
        imagefilterCollectionView.delegate = self
        imagefilterCollectionView.dataSource = self
        
        
        // 이미지가 안눌린 상태로 초기값 설정
        imageTapStatus = false
        
        // 이미지에서 Tap Gesture 받을 수 있게 설정 (기본값은 false)
        photographedImage.isUserInteractionEnabled = true
        
        openGLContext = EAGLContext(api: .openGLES3)
        if let openGLContext = openGLContext {
            ciContext = CIContext(eaglContext: openGLContext)
            
            if let ciContext = ciContext {
                if let cgImage = cameraRelatedCoreImageResource?.cgImage, let ciImage = cameraRelatedCoreImageResource?.ciImage {
                    
                    originalPhotoImage = UIImage(cgImage: ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))!)
//                    photographedImage.image = originalPhotoImage
                    
                    editedCGImage = cgImage
//                    editedCIImage = originalPhotoImage?.ciImage
                    editedCIImage = ciImage
                }
            }
        }
        if let selectedFilterIndex = selectedFilterIndex {
            photographedImage.image = getPreviewPhotoImageWithCIFilter(filterIndex: selectedFilterIndex)
        }
        

      
        
        let photographedImageGestureRecogninzer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageForFullView))
        photographedImage.addGestureRecognizer(photographedImageGestureRecogninzer)
    }
    
    
    // MARK: - View Controller Lifecyle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear in EditPhotoViewController")
        
        
        
        // 콜렉션 뷰의 첫번째 Cell을 선택함.
        guard let selectedFilterIndex = selectedFilterIndex else {
            
            print("selectedFilterIndex error")
            return
            
        }
        
        // 선택된 필터 인덱스에 해당하는 필터 셀 선택
        self.imagefilterCollectionView.selectItem(at: IndexPath.init(item: selectedFilterIndex, section: 0), animated: true, scrollPosition: .bottom)
        
        // 선택된 필터 인덱스에 해당하는 필터 셀 위치로 scroll
        self.imagefilterCollectionView.scrollToItem(at: IndexPath.init(item: selectedFilterIndex, section: 0), at: .centeredHorizontally, animated: true)
        
        
        
        // toolbar show
        navigationController?.isToolbarHidden = true
        
        // navigationBar show
        navigationController?.navigationBar.isHidden = false
        
        
    }
    
    
    
    // filterIndex에 맞게 알맞는 UIImage를 생성
    func getPreviewPhotoImageWithCIFilter(filterIndex : Int) -> UIImage? {
        
        //get CIImage, CGImage from taken Photo
        if let ciImage = cameraRelatedCoreImageResource?.ciImage, let cgImage = cameraRelatedCoreImageResource?.cgImage {
            
            openGLContext = EAGLContext(api: .openGLES3)
            if let openGLContext = openGLContext {
                ciContext = CIContext(eaglContext: openGLContext)
                if let context = ciContext {
            
                    originalPhotoImage = UIImage(cgImage: context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))!)

                    // 선택했던 필터 인덱스로 필터 종류를 가져옴
                    if filterIndex == 0 {
                        //필터 적용이 안된 촬영 사진
//                        originalPhotoImage = UIImage(cgImage: ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))!)

                        previewPhotoImage = UIImage(cgImage: context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))!)
                        
                        print("normal log")
                        return previewPhotoImage
                    } else {
                        let filterName = PhotoEditorTypes.filterNameArray[filterIndex]
                        if let filter = CIFilter(name: filterName) {
                            filter.setDefaults()
                            filter.setValue(ciImage, forKey: kCIInputImageKey)
                            
                            if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                                previewPhotoImage = UIImage(cgImage: context.createCGImage(output, from: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))!)
                                
                                print("filter log")
                                return previewPhotoImage
                                
                            }
                        }
                    }
                }
            }
        }
        
        return UIImage()
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
                
                UIView.animate(withDuration: 0.5, animations: {

                    self.photographedImage.transform = self.photographedImage.transform.rotated(by: CGFloat(M_PI_2))

                    self.transform = self.photographedImage.transform.rotated(by: CGFloat(M_PI_2))
                    self.editedCIImage = self.editedCIImage?.applying(self.transform!)
                    
                })
 
                
                
                
                
                
            default:
                return
            }
        }
    }
    
    
    func getRotatedCGImage(source cgImage: CGImage, transform : CGAffineTransform) -> CGImage? {
        /*
         
         OpenGL ES는 하드웨어 가속 2D 및 3D 그래픽 렌더링을위한 C 기반 인터페이스를 제공합니다. iOS의 OpenGL ES 프레임 워크 (OpenGLES.framework)는 OpenGL ES 사양의 버전 1.1, 2.0 및 3.0 구현을 제공합니다.
         
         EAGL penGL ES 용 플랫폼 별 API
         the platform-specific APIs for OpenGL ES on iOS devices,
         
         */
        
        if let openGLContext = openGLContext {
            ciContext = CIContext(eaglContext: openGLContext)
            if let context = ciContext {
                let ciImage = CIImage(cgImage: cgImage)
                let rotatedCIImage = ciImage.applying(transform)
                return context.createCGImage(rotatedCIImage, from: rotatedCIImage.extent)
            }
        }
        return cgImage
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        var resultImage: UIImage?
        
        
        if segue.identifier == EditPhotoViewController.showAddContentViewControllerSegueIdentifier {
            if let addTextViewController:AddContentViewController = segue.destination as? AddContentViewController {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                
                addTextViewController.edidtedPhotoImage = photographedImage.image
                
                if let context = ciContext {
                    if let editedCIImage = editedCIImage  {
                        
                        addTextViewController.edidtedPhotoImage = UIImage(cgImage: context.createCGImage(editedCIImage, from: editedCIImage.extent)!)
                        
                    }
                }
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
        print("cellForItemAt indexPath.row: ", indexPath.row)
        
        let orginalImage = getPreviewPhotoImageWithCIFilter(filterIndex: indexPath.row)
        
        cell.filterImageView.image = generatePreviewPhoto(source: orginalImage)
        
        
        return cell
    }
    
    
    // cell 선택했을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CameraFillterCollectionViewCell{
            
            selectedCell.isSelected = true
            
            let filterTitle = PhotoEditorTypes.titleForIndexPath(indexPath)
            
            editedCIImage = applyFilterCIImage(target: originalPhotoImage!, type: filterTitle)
            
            if let context = ciContext, let editedCIImage = editedCIImage {
                
                self.photographedImage.image = UIImage(cgImage: context.createCGImage(editedCIImage, from: editedCIImage.extent)!)
                
            }
            
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
    
    
    // image에 fliter 적용하는 메소드
    func applyFilterCIImage(target sourceImage: UIImage, type filterName: String) -> CIImage{
        
        let ciImage = CIImage(cgImage: sourceImage.cgImage!)
        
        if filterName == PhotoEditorTypes.normalStatusFromFilterNameArray() {
            return ciImage
        }
        
        
        if let filter = CIFilter(name: filterName) {
            filter.setDefaults()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let output = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                
                return output
            }
            
        }
        
        return ciImage
    }
    
    
    // MARK:- generate mini preview Photo
    
    // 작은 크기로 보여줄 UIImage를 생성하는 메소드. crop Image -> resize Image
    func generatePreviewPhoto(source image: UIImage?) -> UIImage? {
        
        if let image = image  {
            let widthOfscreenSize:CGFloat = UIScreen.main.bounds.width
            let valueToDivideTheScreen:CGFloat = CGFloat.init(cellUnitValue)
            let widthOfImage = widthOfscreenSize / valueToDivideTheScreen
            
            let croppedImage: UIImage = image.cropToSquareImage()
            
            return croppedImage.resizeImage(targetSize: CGSize(width: widthOfImage, height: widthOfImage))
        }
        return UIImage()
    }
    
    
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
            //            navigationController?.isNavigationBarHidden = true
            editImageEffectToolbar.isHidden = true
            imagefilterCollectionView.isHidden = true
            self.view.backgroundColor = .black
        } else {
            //            navigationController?.isNavigationBarHidden = false
            editImageEffectToolbar.isHidden = false
            imagefilterCollectionView.isHidden = false
            self.view.backgroundColor = .white
        }
    }
}

