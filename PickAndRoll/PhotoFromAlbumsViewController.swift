//
//  PhotoFromAlbumsViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 05/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


@objc
class PhotoFromAlbumsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    var test = [UIImage]()
    var imageArrayLength = 0
    
    var imagesArryFolder = [String]()
    var bigtitle: UIImage!
    var selectedFolderNameIndex = ""
    var folderSharedUIDFromTodoList = [String]()
    public var galleryName:String  = ""
   // var folderName = ""
    var myUserId = ""
    var shareUserID = ""
    
    
    @IBOutlet weak var collectionView: UICollectionView!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "signin-bg")
        self.view.insertSubview(backgroundImage, at: 0)
        
      
        collectionView.backgroundView = UIImageView(image: UIImage(named: "signin-bg"))
         myUserId = FIRAuth.auth()!.currentUser!.uid
        print("myuserd id is-->\(myUserId) and \(selectedFolderNameIndex) \n \(folderSharedUIDFromTodoList.count)")
        galleryName = selectedFolderNameIndex
        
        self.imageArrayLength = self.imagesArryFolder.count
        let kUserDefault = UserDefaults.standard
        kUserDefault.set(folderSharedUIDFromTodoList, forKey: "nameArray")
        kUserDefault.set(selectedFolderNameIndex, forKey: "FolderName")
        kUserDefault.synchronize()
        
        if(self.imageArrayLength == 0){
            print("No photos")
            
            let myAlert = UIAlertController(title: "No photos", message: "Add Photos", preferredStyle:UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
            myAlert.addAction(okAction);
            self.present(myAlert,animated:true,completion:nil);
            
        }
        else{
            
            for i in 0...self.imageArrayLength-1 {
                
                if let url = NSURL(string: self.imagesArryFolder[i] ) {
                    
                    if let imageData = NSData(contentsOf: url as URL) {
                        let str64 = imageData.base64EncodedData(options: .lineLength64Characters)
                        let data: NSData = NSData(base64Encoded: str64 , options: .ignoreUnknownCharacters)!
                        let dataImage = UIImage(data: data as Data)
                        self.bigtitle = dataImage
                        self.test.append(self.bigtitle)
                    }
                    
                }
                
            }
        }
        
 
      
    }
    
    
    //this function is fetching the json from URL
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArryFolder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.allowsMultipleSelection = true
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
                cell.lblName.isHidden = true
               cell.imgImage.image = self.test[indexPath.row]
        
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
               let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.green
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.white
    }
    
    @IBAction func uploadNewPhotoTapped(_ sender: Any) {
      
    }
    
    

    @IBAction func cameraButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = NSData(data:UIImagePNGRepresentation(chosenImage)!)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        var docs: String = paths[0] as! String
        let fullPath = "\(docs)\("/name1.png")"
        
        
        let storageRef = FIRStorage.storage().reference().child(myUserId).child(UUID().uuidString)
        if let uploadData = UIImagePNGRepresentation(chosenImage) as? NSData {
            
                    storageRef.put(uploadData as Data, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    
                } else {
                    print("Image Uploaded Succesfully")
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    print(profileImageUrl!)
                    
                    let ref = FIRDatabase.database().reference(fromURL: "https://pick-n-roll.firebaseio.com/")
                    let userReference = ref.child("Files").child(self.myUserId).child("\(self.galleryName)\(self.myUserId)\(UUID().uuidString)").setValue(profileImageUrl)
                  //  insert images to shared user folder
                    for i in 0...self.folderSharedUIDFromTodoList.count - 1 {
                    let userRef = ref.child("Files").child(self.folderSharedUIDFromTodoList[i]).child("\(self.galleryName)\(self.myUserId)\(UUID().uuidString)").setValue(profileImageUrl)
                    }
                    
                    
                }  
            })
        }
         dismiss(animated:true, completion: nil)

        
    }
    
    
    
}
