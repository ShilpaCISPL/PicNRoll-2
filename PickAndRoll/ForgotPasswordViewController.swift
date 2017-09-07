//
//  ForgotPasswordViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 20/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailForgotTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetButtontapped(_ sender: Any) {
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailForgotTextField.text!, completion: { (error) in
            if error == nil {
                print("An email with information on how to reset your password has been sent to you. thank You")
            }else {
                print(error!.localizedDescription)
                
            }
        })

    }
   


}


