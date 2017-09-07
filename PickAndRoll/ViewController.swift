//
//  ViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 16/06/17.
//  Copyright © 2017 CISPL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import KeychainSwift
import FirebaseAuth
import GoogleMaps
import FirebaseStorage
import FBSDKLoginKit
import GoogleSignIn



class ViewController: UIViewController,CLLocationManagerDelegate,FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    var current_lattitude = 0.0
    var current_longitude = 0.0
    var userID = ""
    var userEmail = ""
    var ref:FIRDatabaseReference?
    var noOfUsers  = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //   setupFacebookButtons()
        
    //    setupGoogleButtons()
        
        
        // Do any additional setup after loading the view.
        
        profileImage.isUserInteractionEnabled = true
        var TapGesture = UITapGestureRecognizer(target: self, action: "ImageTapped")
        self.profileImage.addGestureRecognizer(TapGesture)
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
    fileprivate func setupGoogleButtons() {
        //add google sign in button
        //        let googleButton = GIDSignInButton()
        //        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 100)
        //        view.addSubview(googleButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitle("Custom Google Sign In", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        view.addSubview(customButton)
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    
    func handleCustomGoogleSign() {
        print("Custom google Login successful")
        
        GIDSignIn.sharedInstance().signIn()
        
       }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            print("signout id in view is-->\(FIRAuth.auth()!.currentUser!.uid)")
            
            
        } else {
            print("error")
        }
    }
    
    
    
    
    
    fileprivate func setupFacebookButtons() {
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        //        //add our custom fb login button here
        //        let customFBButton = UIButton(type: .system)
        //        customFBButton.backgroundColor = .blue
        //        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        //        customFBButton.setTitle("Custom FB Login here", for: .normal)
        //        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //        customFBButton.setTitleColor(.white, for: .normal)
        //        view.addSubview(customFBButton)
        //
        //        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        showEmailAddress()
    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
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
        print("current location in view controller -->\(current_lattitude) & \(current_longitude)")
        
        locationManager.stopUpdatingLocation()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = DataService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "SignIn", sender: nil)
            
            userID = FIRAuth.auth()!.currentUser!.uid
            userEmail = (FIRAuth.auth()!.currentUser?.email)!
            
            print("userid is-->\(userID) & \(userEmail)")
            print("current location in login -->\(current_lattitude) & \(current_longitude)")
        }
    }
    
    func CompleteSignIn(id: String){
        let keyChain = DataService().keyChain
        keyChain.set(id , forKey: "uid")
    }
    
    
    
    @IBAction func SignIn(_ sender: Any) {
        
        if let name = nameField.text,let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                   
                    self.CompleteSignIn(id: user!.uid)
                    self.performSegue(withIdentifier: "SignIn", sender: nil)
                    
                    let userSignIn: String = FIRAuth.auth()!.currentUser!.uid
                    let userEmailIn : String = (FIRAuth.auth()!.currentUser?.email)!
                    
                    
                    
                }
            }
        }
    }
    
    
    @IBAction func SignUp(_ sender: Any) {
        if let name = nameField.text,let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                
                
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
                            
                            let values = ["Name":name,"Email":email,"profileImageUrl":profileImageUrl,"lat":String(self.current_lattitude),"lng":String(self.current_longitude)]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                        
                        
                    })
                }
                self.performSegue(withIdentifier: "SignIn", sender: nil)
                //                self.ref?.child("Users").child(usernumber).child("Name").setValue("Vikas")
                
                
            }
        }
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

