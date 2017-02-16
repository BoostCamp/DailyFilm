//
//  DiaryContentTableViewCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 16..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

// 사진의 내용을 클릭하여 DetailView로 이동시키기 위한 delegation 프로토콜
protocol ContentLabelDelegate {
    func showDetailContent(sender: DiaryContentTableViewCell)
}

class DiaryContentTableViewCell: UITableViewCell {
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func tapContentLabel(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.showDetailContent(sender: self)
        }
    }
}
