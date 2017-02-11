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
        didSet {
            // if가 더 컴파일 속도가 빠름
            self.filterTitleLabel.textColor = isSelected ? UIColor.black : UIColor.gray
        }
    }
}
