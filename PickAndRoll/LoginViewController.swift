//
//  LoginViewController.swift
//  PickAndRoll
//
//  Created by Badrinath kangundi on 21/07/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import KeychainSwift
import FirebaseAuth
import GoogleMaps
import FirebaseStorage

class LoginViewController: UIViewController,CLLocationManagerDelegate {
    
    
    var userID = ""
    var userEmail = ""
    
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    
    @IBOutlet weak var passwordField: UITextField!
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    var current_lattitude = 0.0
    var current_longitude = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let camera = GMSCameraPosition.camera(withLatitude: 12.971599, longitude: 77.594563, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        // view = mapView
        
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "SignIn", sender: nil)
        }
    }
    
    
    func CompleteSignIn(id: String){
        let keyChain = DataService().keyChain
        keyChain.set(id , forKey: "uid")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        //  self.view = mapView
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        marker.map = self.mapView
        current_lattitude = userLocation!.coordinate.latitude
        current_longitude = userLocation!.coordinate.longitude
        locationManager.stopUpdatingLocation()
    }
    
    
    @IBAction func SIGNIN(_ sender: Any) {
        
        if ((emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (nameField.text?.isEmpty)!) {
            let myAlert = UIAlertController(title: "Alert", message: "All fields are required", preferredStyle:UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
            myAlert.addAction(okAction);
            self.present(myAlert,animated:true,completion:nil);
        }
        else {
            
            if let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        self.CompleteSignIn(id: user!.uid)
                        self.performSegue(withIdentifier: "SignIn", sender: nil)
                        print("user loged")
                    }
                }
            }
        }
    }
    
    
    @IBAction func SignUp(_ sender: Any) {
        
        
        if ((emailField.text?.isEmpty)! || (passwordField.text?.isEmpty)! || (nameField.text?.isEmpty)!) {
            let myAlert = UIAlertController(title: "Alert", message: "All fields are required", preferredStyle:UIAlertControllerStyle.alert);
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
            myAlert.addAction(okAction);
            self.present(myAlert,animated:true,completion:nil);
        }
        else {
            
            if let email = emailField.text, let password = passwordField.text,let name = nameField.text {
                FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                    
                    var uid = user?.uid
                    
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("picknroll_profile_images").child("\(imageName).png")
                    var profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/pickandroll-e0897.appspot.com/o/pickroll_profile_images%2F002DE673-58CA-4170-A9D8-D58EBEDE643F.png?alt=media&token=405717b8-4046-4d32-ab4c-13b93165050f"
                    let values = ["Name":name,"Email":email,"profileImageUrl":profileImageUrl,"lat":String(self.current_lattitude),"lng":String(self.current_longitude)]
                    self.registerUserIntoDatabaseWithUID(uid: uid!, values: values as [String : AnyObject])
                    
                    self.performSegue(withIdentifier: "SignIn", sender: nil)
                    print("created new \(imageName)")
                }
            }
        }
        
    }
    private func registerUserIntoDatabaseWithUID(uid:String,values:[String:AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://pick-n-roll.firebaseio.com/")
        
        let userReference = ref.child("Users").child(uid)
        
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            
        })
        
    }
    
}
