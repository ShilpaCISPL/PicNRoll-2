//
//  SignOutCode.swift
//  Authorize
//
//  Created by Shilpa S L
//  Copyright © 2017 Shilpa S L. All rights reserved.
//

import UIKit
import Firebase

import GoogleSignIn

class SignOutCode: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        print("signout id is-->\(FIRAuth.auth()!.currentUser!.uid)")
    }
    
    
    
    @IBAction func SignOut (_ sender: Any){
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        
        DataService().keyChain.delete("uid")
        dismiss(animated: true, completion: nil)
    }
    
    
}
