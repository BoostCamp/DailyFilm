//
//  DiaryPhotoTableViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 15..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class DiaryPhotoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNicknameLabel: UILabel!
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
}
