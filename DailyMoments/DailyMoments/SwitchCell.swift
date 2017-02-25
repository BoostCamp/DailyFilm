//
//  SwitchCell.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 23..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate {
    func switchCellDidChangeSwitchValue(sender: SwitchCell)
}


class SwitchCell: UITableViewCell {
    
    weak var onOffSwitch: UISwitch!
    
    var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
        self.accessoryView = UISwitch()
        onOffSwitch = self.accessoryView as? UISwitch
        onOffSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)),
                              for: UIControlEvents.valueChanged)
    }
    
    
    func switchValueChanged(sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.switchCellDidChangeSwitchValue(sender: self)
        }
    }
}
