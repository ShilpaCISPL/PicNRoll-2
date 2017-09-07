//
//  SideMenuViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 16/06/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var btnMenuButton: UIBarButtonItem!
        override func viewDidLoad() {
        super.viewDidLoad()
            
            
            
         
            if revealViewController() != nil {
                //            revealViewController().rearViewRevealWidth = 62
                btnMenuButton.target = revealViewController()
                btnMenuButton.action = "revealToggle:"
                
                //            revealViewController().rightViewRevealWidth = 150
                //            extraButton.target = revealViewController()
                //            extraButton.action = "rightRevealToggle:"
                
                
                
                
            }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
