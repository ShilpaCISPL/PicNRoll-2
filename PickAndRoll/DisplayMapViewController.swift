//
//  DisplayMapViewController.swift
//  PickAndRoll
//
//  Created by Shilpa-CISPL on 16/06/17.
//  Copyright © 2017 CISPL. All rights reserved.


import UIKit
import GoogleMaps

class DisplayMapViewController: UIViewController,CLLocationManagerDelegate {
    
    
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    var lattitudes = [Double]()
    var longitudes = [Double]()
    var names = [String]()
    var lattitude = 0.0
    var longitude = 0.0
    var responseArraySize = 0
    let URL_HEROES = "https://pick-n-roll.firebaseio.com/Users.json";
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        revealViewController().rearViewRevealWidth = 200
        menu.target = revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 13.
        let camera = GMSCameraPosition.camera(withLatitude: 12.971599, longitude: 77.594563, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        //  mapView.settings.myLocationButton = true
     //   view = mapView
        
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        getJsonFromUrl()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            
        marker.map = self.mapView
        print("current location is-->\(userLocation!.coordinate.latitude)")
        locationManager.stopUpdatingLocation()
        print("current location after update-->\(userLocation!.coordinate.latitude)")
        
    }
    
    //this function is fetching the json from URL
    func getJsonFromUrl(){
        //creating a NSURL
        let url = NSURL(string: URL_HEROES)
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let newArray = (jsonObj?.allValues)! as? NSArray
                
                self.responseArraySize = (newArray?.count)!
                
                for index in 0...self.responseArraySize-1 {
                    
                    let name:String? = (newArray?[index] as AnyObject).value(forKey: "Name") as? String
                    let lat: String? = (newArray?[index] as AnyObject).value(forKey: "lat") as? String
                    let lng: String? = (newArray?[index] as AnyObject).value(forKey: "lng") as? String
                    
                    self.lattitude = Double(lat!)!
                    self.longitude = Double(lng!)!
                    self.names.append(name!)
                    self.lattitudes.append(self.lattitude)
                    self.longitudes.append(self.longitude)
                    
                    print("TotalArrayValues are-->\(lat!) & \(lng!) & \((newArray?.count)!) & \(self.lattitudes.count) & \(self.longitudes.count) ")
                    
                }
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    //it will show the names to label
                    // self.showNames()
                    
                })
                
                DispatchQueue.main.async(execute: {
                    self.responseArraySize = (newArray?.count)!
                    print("responseArraySizeDispatch is -->\(self.responseArraySize)")
                    
                    for i in 0...self.responseArraySize-1 {
                        
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: self.lattitudes[i], longitude: self.longitudes[i])
                        marker.icon = GMSMarker.markerImage(with: UIColor.red)
                        marker.title = self.names[i]
                        marker.map = self.mapView
                    }
                })
                
            }
        }).resume()
        
        
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
