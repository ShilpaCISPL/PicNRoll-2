//

//  menuViewController.swift

//  PickAndRoll

//

//  Created by Shilpa-CISPL on 16/06/17.

//  Copyright © 2017 CISPL. All rights reserved.



import UIKit

import FirebaseDatabase

import FirebaseAuth

import FirebaseStorage





class menuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var tblTableView: UITableView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    var ManuNameArray:Array = [String]()
    
    var userFolderDashboard = [String]()
    
    var imaheKeysFromDB = [String]()
    
    var userKeys = [String]()
    
    var iconArray:Array = [UIImage]()
    
    var loggedUserEmail = ""
    
    var myUserId = ""
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        myUserId = FIRAuth.auth()!.currentUser!.uid
        
        loggedUserEmail = FIRAuth.auth()!.currentUser!.email!
        
        //Get profileImage
        
        let urlImage = NSURL(string: "https://pick-n-roll.firebaseio.com/Users/\(myUserId)/profileImageUrl.json")
        //fetching the data from the url
        
        URLSession.shared.dataTask(with: (urlImage as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSString {
                OperationQueue.main.addOperation({
                    
                })
                
                DispatchQueue.main.async(execute: {
                    
                    if let url = NSURL(string: jsonObj! as String) {
                        
                        if let imageData = NSData(contentsOf: url as URL) {
                            
                            let str64 = imageData.base64EncodedData(options: .lineLength64Characters)
                            
                            let data: NSData = NSData(base64Encoded: str64 , options: .ignoreUnknownCharacters)!
                            
                            let dataImage = UIImage(data: data as Data)
                            
                            self.imgProfile.image = dataImage
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }).resume()
        
        //Read user folders
        
        var URL_IMAGES_DB = "https://pick-n-roll.firebaseio.com/Albums/\(FIRAuth.auth()!.currentUser!.uid).json"
        
        let url = NSURL(string: URL_IMAGES_DB)
        
        //fetching the data from the url
        
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                
                //  print("jsonObj is -->\(jsonObj!)")
                
                if(jsonObj == nil){
                    print("Nofolder")
                }
                else {
                    self.userFolderDashboard = (jsonObj as! NSArray as? [String])!
                    
                }
                
                OperationQueue.main.addOperation({
                    
                })
                DispatchQueue.main.async(execute: {
                    
                })
                
                
            }
            
        }).resume()
        
        
        //Get all user id's
        
        //Read user folders
        var URL_USERS_DB = "https://pick-n-roll.firebaseio.com/Users.json"
        
        let url_URL_USERS_DB = NSURL(string: URL_USERS_DB)
        
        //fetching the data from the url
        
        URLSession.shared.dataTask(with: (url_URL_USERS_DB as? URL)!, completionHandler: {(data, response, error) -> Void in
            if let jsonObjUsers = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                self.userKeys = (jsonObjUsers?.allKeys)! as? NSArray as! [String]
                
                OperationQueue.main.addOperation({
                    
                })
                
                DispatchQueue.main.async(execute: {
                    
                })
                
            }
            
        }).resume()
        
        //Get all keys from DB
        
        let dbRef = FIRDatabase.database().reference().child("Files").child(myUserId).child("Testing")
        
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            // Get download URL from snapshot
            
            let downloadURL = snapshot.value as! String
            
            let urlKey = snapshot.key as! String
            
            self.imaheKeysFromDB.append(urlKey)
            
        })
        
        
        ManuNameArray = ["Dashboard","MyProfile","Map","Logout"]
        iconArray = [UIImage(named:"home")!,UIImage(named:"message")!,UIImage(named:"map")!,UIImage(named:"setting")!]
        
        
        //Rounded image
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor.green.cgColor
        imgProfile.layer.cornerRadius = 50
        imgProfile.layer.masksToBounds = false
        imgProfile.clipsToBounds = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapDetected"))
        
        singleTap.numberOfTapsRequired = 1 // you can change this value
        
        imgProfile.isUserInteractionEnabled = true
        
        imgProfile.addGestureRecognizer(singleTap)
    }
    
    
    func tapDetected() {
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
            
            imgProfile.image = selectedImage
            
            //successfully authenticated user
            
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("pickroll_profile_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(imgProfile.image!) {
                
                storageRef.put(uploadData, metadata: nil, completion: {(metadata,error) in
                    
                    if error != nil {
                        
                        print(error)
                        
                        return
                        
                    }
                    
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        
                        let values = ["Email":self.loggedUserEmail,"profileImageUrl":profileImageUrl]
                        
                        self.changeProfilePicInDatabase(myUserId:self.myUserId,values:values as [String : AnyObject] )
                        
                    }
                    
                })
                
            }
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("canceled picker")
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func changeProfilePicInDatabase(myUserId:String,values:[String:AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://pick-n-roll.firebaseio.com/")
        let userReference = ref.child("Users").child(myUserId)
        
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                
                print(err)
                
                return
                
            }
            
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ManuNameArray.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        cell.lblMenuname.text! = ManuNameArray[indexPath.row]
        
        cell.imgIcon.image = iconArray[indexPath.row]
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let revealviewcontroller:SWRevealViewController = self.revealViewController()
        
        let cell:MenuCell = tableView.cellForRow(at: indexPath) as! MenuCell
              if cell.lblMenuname.text! == "Dashboard"
            
        {
                      let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "ToDoListTableViewController") as! ToDoListTableViewController
            
            newViewcontroller.userFolders = self.userFolderDashboard
            
            newViewcontroller.userKeysFromDB = self.userKeys
            
            newViewcontroller.imageKeys = self.imaheKeysFromDB
            
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
          
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
            
        }
        
        if cell.lblMenuname.text! == "MyProfile"
            
        {
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
            
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
        }
        
        if cell.lblMenuname.text! == "Map"
            
        {
            
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let newViewcontroller = mainstoryboard.instantiateViewController(withIdentifier: "MapVC") as! DisplayMapViewController
            
            let newFrontController = UINavigationController.init(rootViewController: newViewcontroller)
            
            revealviewcontroller.pushFrontViewController(newFrontController, animated: true)
            
        }
        
        if cell.lblMenuname.text! == "Logout"
            
        {
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

}

