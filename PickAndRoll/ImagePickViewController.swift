//
//  ImagePickViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 19/06/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ImagePickViewController: UIViewController {

    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    


    @IBAction func btnSave(_ sender: Any) {
       //   handleRegister()
        
      //   let name = nameField.text ,let email = emailField.text, let password = passwordField.text
        var email = emailField.text
        var password = passwordField.text
        var name = nameField.text
        
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user: FIRUser?, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("pickroll_profile_images").child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
                
                storageRef.put(uploadData, metadata: nil, completion: {(metadata,error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["Name":name,"Email":email,"profileImageUrl":profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                              })
            }
            
        })
        
        
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String,values:[String:AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://pickandroll-e0897.firebaseio.com/")
        // let userReference = ref.child("UserDetails").child("User1").child(uid)
        let userReference = ref.child("Users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
      
        // Do any additional setup after loading the view.
        
        profileImage.isUserInteractionEnabled = true
        var TapGesture = UITapGestureRecognizer(target: self, action: "ImageTapped")
        self.profileImage.addGestureRecognizer(TapGesture)
        
         }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
