

//
//  menuViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 09/10/16.
//  Copyright © 2017 CISPL. All rights reserved.


import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var lblMenuname: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
