
//
//  NewToDoTableViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 05/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit

class NewToDoTableViewController: UITableViewController {

    @IBOutlet weak var toDoItemTextField: UITextField!
    var toDoItem: String?
      
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            toDoItemTextField.becomeFirstResponder()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    
       // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "saveToToDoList" {
            
            toDoItem = toDoItemTextField.text
           
        
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
