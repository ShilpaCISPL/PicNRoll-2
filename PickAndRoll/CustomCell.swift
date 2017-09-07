//
//  CustomCell.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 06/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
      //  photo.layer.borderWidth = 0.01
        photo.layer.masksToBounds = false
        photo.layer.borderColor = UIColor.black.cgColor
        photo.layer.cornerRadius = 50
        photo.clipsToBounds = true
    }

}
