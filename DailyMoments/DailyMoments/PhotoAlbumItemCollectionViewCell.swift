//
//  PhotoAlbumItemCollectionViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 23..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class PhotoAlbumItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isSelected {
            self.photoImageView.layer.borderColor = UIColor.easyColor(red: 5, green: 197, blue: 144).cgColor
            self.photoImageView.layer.borderWidth = 3
        } else {
            self.photoImageView.layer.borderColor = UIColor.clear.cgColor
            self.photoImageView.layer.borderWidth = 0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                self.photoImageView.layer.borderColor = UIColor.easyColor(red: 5, green: 197, blue: 144).cgColor
                self.photoImageView.layer.borderWidth = 3
            } else {
                self.photoImageView.layer.borderColor = UIColor.clear.cgColor
                self.photoImageView.layer.borderWidth = 0
            }
        }
    }
    
}
