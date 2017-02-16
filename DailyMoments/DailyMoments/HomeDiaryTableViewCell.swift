//
//  HomeDiaryTableViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 15..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit


protocol ContentLabelDelegate {
    func showDetailContent(sender: HomeDiaryTableViewCell)
}


class HomeDiaryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    
    
    var delegate: ContentLabelDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentLabel.isUserInteractionEnabled = true
        
        let gestureRecognizerOfContentLabel: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapContentLabel(sender:)))
        
        contentLabel.addGestureRecognizer(gestureRecognizerOfContentLabel)
        
    }
    
    func tapContentLabel(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.showDetailContent(sender: self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
