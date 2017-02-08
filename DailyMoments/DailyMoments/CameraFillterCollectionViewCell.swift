//
//  CameraFillterCollectionViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 8..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class CameraFillterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        filterTitleLabel.textColor =  self.isSelected ? UIColor.black : UIColor.gray
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                super.isSelected = true
                self.filterTitleLabel.textColor = UIColor.black
            } else if newValue == false {
                super.isSelected = false
                self.filterTitleLabel.textColor = UIColor.gray
            }
        }
    }
    
}
