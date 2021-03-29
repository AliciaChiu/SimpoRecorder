//
//  CustomTableViewCell.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/29.
//

import UIKit


protocol CustomTableViewCellDelegate {
    func popEditingAlert(indexPath: IndexPath)
}


class CustomTableViewCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var delegate: CustomTableViewCellDelegate?

    var audioIndexPath: IndexPath?

    
    @IBAction func edit(_ sender: UIButton) {
        if let indexPath = self.audioIndexPath {
            self.delegate?.popEditingAlert(indexPath: indexPath)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

 }

