//
//  DiaryPhotoTableViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 15..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit


// 사진의 내용을 클릭하여 DetailView로 이동시키기 위한 delegation 프로토콜
protocol DiaryHomeTableViewControllerDelegate {
    func AdditionalActions(sender: DiaryPhotoTableViewCell)
}


class DiaryPhotoTableViewCell: UITableViewCell {
    
    var delegate: DiaryHomeTableViewControllerDelegate?
    
    @IBOutlet weak var photoImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func clickAdditionalActionButton(_ sender: Any) {
        if let delegate = delegate {
            delegate.AdditionalActions(sender: self)
        }
    }
    
    
}
