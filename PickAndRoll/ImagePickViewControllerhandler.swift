//
//  ImagePickViewControllerhandler.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 19/06/17.
//  Copyright © 2017 CISPL. All rights reserved.
//


import UIKit
import Firebase
import FirebaseStorage

extension ImagePickViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleRegister() {
       //  let email = "shilpa@gmail.com", let password = "123456", let name = "shilpa"
       var email = "vikas@gmail.com"
        var password = "123456"
        var name = "vikas"
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
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
    
    func ImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
}
