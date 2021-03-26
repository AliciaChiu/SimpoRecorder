//
//  CustomTableViewCell.swift
//  HelloRecordAudio
//
//  Created by Alicia Chiu on 2020/10/29.
//

import UIKit



class CustomTableViewCell: UITableViewCell{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

 }

