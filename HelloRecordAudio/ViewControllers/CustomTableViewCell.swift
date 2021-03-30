//
//  CustomTableViewCell.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/29.
//

import UIKit


protocol CustomTableViewCellDelegate {
    func popEditingAlert(record: Record)
}


class CustomTableViewCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var delegate: CustomTableViewCellDelegate?
    var record: Record!
    
    @IBAction func edit(_ sender: UIButton) {
        self.delegate?.popEditingAlert(record: self.record)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 }

