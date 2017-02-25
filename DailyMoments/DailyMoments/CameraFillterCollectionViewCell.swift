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
        
        if isSelected {
            self.filterTitleLabel.textColor = UIColor.black
        } else {
            self.filterTitleLabel.textColor = UIColor.gray
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                self.filterTitleLabel.textColor = UIColor.black
            } else {
                self.filterTitleLabel.textColor = UIColor.gray
            }
        }
    }
}
