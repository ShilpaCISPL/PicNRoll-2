//
//  CustomFolderCell.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 25/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit

class CustomFolderCell: UITableViewCell {

    
    @IBOutlet weak var folderNameTextView: UITextView!
    
    @IBOutlet weak var folderImageView: UIImageView!
    
    @IBOutlet weak var imageCountTextField: UITextView!
    
    
    @IBOutlet weak var sharedUsersCount: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    }
