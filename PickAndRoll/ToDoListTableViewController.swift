//
//  ToDoListTableViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 05/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ToDoListTableViewController: UITableViewController,UINavigationBarDelegate,UINavigationControllerDelegate {
    
    var items: [Array<String>] = [[String]()]
    var folderName = ""
    var folderIndex = 0
    var imagesFromDB = [String]()
    var imageKeys = [String]()
    var userId = ""
    
    var userFolders = [String]()
    var userKeysFromDB = [String]()
    var sharedUsers = ""
    var sharedUsersArray = [String]()
    var folderSharedUID = [String]()
    var arrOfAlbumSharedUsers = [String]()
   
    @IBOutlet weak var menu: UIBarButtonItem!
     @IBAction func cancelToToDoList(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func saveToToDoList(_ segue: UIStoryboardSegue) {
        
        let newToDoViewController = segue.source as! NewToDoTableViewController
        
        if let newItem = newToDoViewController.toDoItem {
            items[0].append(newItem)
            self.arrOfAlbumSharedUsers.append("0")
            tableView.reloadData()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
           tableView.backgroundView = UIImageView(image: UIImage(named: "signin-bg"))
        
        userId = FIRAuth.auth()!.currentUser!.uid
               sharedUsers = String(self.sharedUsersArray.count)
        
        
        let dbRef = FIRDatabase.database().reference().child("Files").child(userId)
        dbRef.observe(.childAdded, with: { (snapshot) in
            // Get download URL from snapshot
            let downloadURL = snapshot.value as! String
            let urlKey = snapshot.key as! String
            self.imageKeys.append(urlKey)
            print("IMAGEKEYS are-->\(self.imageKeys)")
            self.imagesFromDB.append(downloadURL);
            
            
        })
        
        
        var URL_IMAGES_DB = "https://pick-n-roll.firebaseio.com/Albums/\(FIRAuth.auth()!.currentUser!.uid).json"
        let url = NSURL(string: URL_IMAGES_DB)
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                
                if(jsonObj == nil) {
                    let myAlert = UIAlertController(title: "No folders", message: "Add new folder", preferredStyle:UIAlertControllerStyle.alert);
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
                    myAlert.addAction(okAction);
                    self.present(myAlert,animated:true,completion:nil);
                    
                }
                else {
                    if let userFolders = jsonObj as! NSArray as? [String] {
                        
                        for j in 0...userFolders.count-1 {
                            
                            self.items[0].append(userFolders[j])
                            
                        }
                    }
                }
                OperationQueue.main.addOperation({
                    
                })
                
                DispatchQueue.main.async(execute: {
                    
                    self.tableView.reloadData()
                })
                
                
            }
        }).resume()
        
        
        
        //Read album shared count
        
        FIRDatabase.database().reference().child("SharedUsers/\(FIRAuth.auth()!.currentUser!.uid)").observeSingleEvent(of: .value, with: {(snap) in
            
            if(snap.exists()){
                var countDict = snap.value as! NSDictionary
                var dict_keys = Array(countDict.allKeys)
                var dict_values = Array(countDict.allValues)
                for i in 0...dict_keys.count - 1 {
                    var dictValues = dict_values[i] as! NSDictionary
                    
                    var gallery_count = "\(dict_keys[i]) : \(dictValues.count)"
                   
                    self.arrOfAlbumSharedUsers.append(String(dictValues.count))
                    print("arrOfAlbumSharedUsers is -->\(self.arrOfAlbumSharedUsers)")
                    
                }
            }
            else {
                print("NO SharedUserUID")
            }
            
        })
        
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomFolderCell
        
        cell.folderNameTextView.text = items[indexPath.section][indexPath.row]
               cell.imageCountTextField.isHidden = true
              let sections: Int = tableView.numberOfSections
        var rows: Int = 0
        
        for i in 0..<sections {
            rows += tableView.numberOfRows(inSection: i)
        }
        
        if(rows == self.arrOfAlbumSharedUsers.count){
            cell.sharedUsersCount.text = self.arrOfAlbumSharedUsers[indexPath.row]
            
        }
        else  {
            self.arrOfAlbumSharedUsers.append("0")
            cell.sharedUsersCount.text = self.arrOfAlbumSharedUsers[indexPath.row]
            
            
        }
                folderName = items[indexPath.section][indexPath.row]
        folderIndex = indexPath.row
               var shareArr = [String]()
        for i in self.imageKeys {
            
            if (i.range(of: userId) == nil) {
                shareArr.append(i)
                
            }
            else {
                
            }
            
            
        }
              let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Albums").child(FIRAuth.auth()!.currentUser!.uid).child(String(folderIndex)).setValue(items[indexPath.section][indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var columnindex = String(indexPath.item)
        
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomFolderCell
        var folderText = currentCell.folderNameTextView!.text!
        
        var resultStr = "(\(columnindex)\(items[indexPath.section][indexPath.row]))"
        var folderImages = [String]()
        
        if(self.imageKeys.count == 0){
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showAlbum") as! PhotoFromAlbumsViewController
            nextViewController.imagesArryFolder = folderImages
            nextViewController.selectedFolderNameIndex = resultStr
            nextViewController.folderSharedUIDFromTodoList = self.folderSharedUID
            self.present(nextViewController, animated:true, completion:nil)
            
        }
        else {
            
            let refreshAlert = UIAlertController(title: "Alert", message: "Want to share folder?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                               for k in 0...self.imageKeys.count-1 {
                    if(self.imageKeys[k].contains(currentCell.folderNameTextView!.text!)){
                        folderImages.append(self.imagesFromDB[k])
                       
                        
                    }
                }
                
                if(folderImages.isEmpty){
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showAlbum") as! PhotoFromAlbumsViewController
                    nextViewController.imagesArryFolder = folderImages
                    nextViewController.selectedFolderNameIndex = resultStr
                    
                    nextViewController.folderSharedUIDFromTodoList = self.folderSharedUID
                   
                    self.present(nextViewController, animated:true, completion:nil)
                    
                }
                    //Open Userlist view controller to share folder
                else {
                    
                    
                    FIRDatabase.database().reference().child("SharedUsers/\(FIRAuth.auth()!.currentUser!.uid)/\(folderText)").observeSingleEvent(of: .value, with: {(snap) in
                        
                        if(snap.exists()){
                            var countDict = snap.value as! NSDictionary
                            var dict_values = Array(countDict.allValues)
                            
                            for i in 0...dict_values.count - 1 {
                                self.folderSharedUID.append(dict_values[i] as! String)
                            }
                           
                        }
                        
                        else {
                            print("NO ALBUMS")
                        }
                    })
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showUsers") as! UsersListViewController
                    
                    nextViewController.imagesFromFolder = folderImages
                    print(folderImages.count)
                    nextViewController.folderIndex = columnindex
                    nextViewController.sharedfolderName = folderText
                    nextViewController.gallerySharedUsers = self.folderSharedUID
                    self.present(nextViewController, animated:true, completion:nil)
                }
           
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                
                for k in 0...self.imageKeys.count-1 {
                    if(self.imageKeys[k].contains(currentCell.folderNameTextView!.text!)){
                        folderImages.append(self.imagesFromDB[k])
                        print("folderimages count\(folderImages)")
                        
                    }
                }

                
                FIRDatabase.database().reference().child("SharedUsers/\(FIRAuth.auth()!.currentUser!.uid)/\(folderText)").observeSingleEvent(of: .value, with: {(snap) in
                    
                    if(snap.exists()){
                        var countDict = snap.value as! NSDictionary
                        var dict_values = Array(countDict.allValues)
                        
                        for i in 0...dict_values.count - 1 {
                            self.folderSharedUID.append(dict_values[i] as! String)
                        }
                                               let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showAlbum") as! PhotoFromAlbumsViewController
                        nextViewController.imagesArryFolder = folderImages
                        nextViewController.selectedFolderNameIndex = resultStr
                       // nextViewController.folderName = currentCell.folderNameTextView!.text!
                        print("FOUR")
                        nextViewController.folderSharedUIDFromTodoList = self.folderSharedUID
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                        
                        
                    else {
                        print("NO ALBUMS")
                    }
                })
           
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        }
        
          }
    
    
    
    
    
}
