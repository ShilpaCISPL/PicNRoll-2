//

//  UsersListViewController.swift

//  PickAndRoll

//

//  Created by Shilpa-CISPL on 06/07/17.

//  Copyright © 2017 CISPL. All rights reserved.

//


import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageCache
import FirebaseStorage


class UsersListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue"
    
    var names = [String]()
    var imagesArryFolder = [String]()
    var folderIndex = ""
    var profileImages = [UIImage]()
    var arrayOfUid = [String]()
    var username = ""
    var imageName = [UIImage(named: "home"),UIImage(named: "profile"),UIImage(named: "map")]
    var responseArraySize = 0
    var userId = ""
var imagesFromFolder = [String]()
    var selectedUserIndex = 0
    var sharedfolderName = ""
    var albumcount = 0
    var sharedUID = [String]()
    var sharedUserCount = 0
    var gallerySharedUsers = [String]()
    var folderSharedUID = [String]()
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    var imageCache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let myUserId = FIRAuth.auth()!.currentUser!.uid
        
        let email = FIRAuth.auth()!.currentUser!.email
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "signin-bg"))
        
        userId = myUserId
        
        //creating a NSURL
        
        let url = NSURL(string: "https://pick-n-roll.firebaseio.com/Users.json")
        
        
        //fetching the data from the url
        
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                self.arrayOfUid = (jsonObj!.allKeys) as? NSArray as! [String]
                
                let newArray = (jsonObj?.allValues)! as? NSArray
                
                self.responseArraySize = (newArray?.count)!
                
                for index in 0...self.responseArraySize-1 {
                    
                    let name:String? = (newArray?[index] as AnyObject).value(forKey: "Name") as? String
                    
                    let emailDB = (newArray?[index] as AnyObject).value(forKey: "Email") as? String
                    
                    let profileImageUrl = (newArray?[index] as AnyObject).value(forKey: "profileImageUrl") as? String
                    
                    self.username = name!
                    
                    self.imagesArryFolder.append(profileImageUrl!)
                    
                    self.names.append(self.username)
                    
                    if(emailDB == email){
                        
                        let name:String? = (newArray?[index] as AnyObject).value(forKey: "Name") as? String
                        
                        let index = self.names.index(of: name!)
                        
                        self.arrayOfUid.remove(at: index!)
                        
                        self.names.remove(at: index!)
                        
                    }
                    
                }
                
                OperationQueue.main.addOperation({
                    
                })
                
                DispatchQueue.main.async(execute: {
                    
                    self.tableView.reloadData()
                    
                })
                
            }
            
        }).resume()
        
        
        FIRDatabase.database().reference().child("SharedUsers/\(FIRAuth.auth()!.currentUser!.uid)/\(sharedfolderName)").observeSingleEvent(of: .value, with: {(snap) in
            
            if(snap.exists()){
                var countDict = snap.value as! NSDictionary
                var dict_values = Array(countDict.allValues)
                
                for i in 0...dict_values.count - 1 {
                    self.folderSharedUID.append(dict_values[i] as! String)
                }
            }
                
            else {
                print("NO Shared Users")
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.names.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
  
        cell.name.text = self.names[indexPath.row]
        print("index is-->\(indexPath.row)")
        
        let imageUrl:NSURL = NSURL(string: self.imagesArryFolder[indexPath.row + 1])!
        let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
        let imageView = UIImageView(frame: CGRect(x:10, y:10, width:cell.frame.size.width, height:cell.frame.size.height))
        
        
        DispatchQueue.main.async {
            
            let image = UIImage(data: imageData as Data)
            cell.photo.image = image
                       cell.addSubview(imageView)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedUserIndex = indexPath.row
        if folderSharedUID.contains(arrayOfUid[indexPath.row]) {
            let myAlert = UIAlertController(title: "Share Album", message: "Already shared", preferredStyle:UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
            
            myAlert.addAction(okAction);
            
            self.present(myAlert,animated:true,completion:nil);
            
        }
        else {
            insertImagesToDB()
            
            getCount()
            
            //Save shared user in DB
            
            let databaseRef = FIRDatabase.database().reference()
            
            databaseRef.child("SharedUsers").child(FIRAuth.auth()!.currentUser!.uid).child(sharedfolderName).childByAutoId().setValue(arrayOfUid[indexPath.row])
            
            let myAlert = UIAlertController(title: "Share Album", message: "Album shared", preferredStyle:UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
            
            myAlert.addAction(okAction);
            
            self.present(myAlert,animated:true,completion:nil);
        }
        
    }
    func insertImagesToDB(){
        
        var ref: FIRDatabaseReference!
        
        var ref2: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference()
        
        ref2 = ref.child("Files").child(arrayOfUid[selectedUserIndex])
        
        for i in 0...self.imagesFromFolder.count-1 {
            
            var folderImages1 = userId.appending(String(folderIndex))
            
            var folderImages =   String(folderIndex)!.appending(userId)
            
            let imageNumber = String(format:"%@%d", folderImages, i)
            
            var imageName = imagesFromFolder[i]
            
            ref2.child(imageNumber).setValue(imageName)
            
        }
        
    }
    
    func getCount(){
        
        //creating a NSURL
        
        let url = NSURL(string: "https://pick-n-roll.firebaseio.com/Albums/\(arrayOfUid[selectedUserIndex]).json")
        
        //fetching the data from the url
        
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                
                if(jsonObj == nil) {
                    self.albumcount = 0
                    
                    var ref: FIRDatabaseReference!
                    
                    var ref2: FIRDatabaseReference!
                    
                    ref = FIRDatabase.database().reference()
                    
                    ref2 = ref.child("Albums").child(self.arrayOfUid[self.selectedUserIndex])
                    
                    ref2.child(String(self.albumcount)).setValue(self.sharedfolderName)
                    
                }
                    
                else {
                    
                    var responseArraySize = (jsonObj?.count)!
                    
                    self.albumcount = responseArraySize
                    
                    self.insertAlbum()
                    
                }
                
                DispatchQueue.main.async(execute: {
                    
                })
                
            }
            
        }).resume()
        
    }
    
    func insertAlbum(){
        
        for k in 0...self.albumcount-1{
            
            var ref: FIRDatabaseReference!
            
            var ref2: FIRDatabaseReference!
            
            ref = FIRDatabase.database().reference()
            
            ref2 = ref.child("Albums").child(arrayOfUid[selectedUserIndex])
            
            ref2.child(String(self.albumcount)).setValue(sharedfolderName)
            
        }
        
    }
    
}
