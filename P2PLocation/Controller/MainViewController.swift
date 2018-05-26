//
//  MainViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/16/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import MapKit
import CoreLocation
import Firebase
import SKActivityIndicatorView
import UserNotifications

class MainViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var compassView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var compassImg: UIImageView!
    @IBOutlet var addresslabel: UILabel!
    
    var appDelegate: AppDelegate!
    
    //MARK: Location Manager - CoreLocation Framework.
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //MARK: Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    //MARK: BackgroundTaskIdentifier for backgrond update location
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    var backgroundTaskIdentifier2: UIBackgroundTaskIdentifier!

    let regionRadius: CLLocationDistance = 1000
    var first: Bool = false
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var requestArray: [NSDictionary] = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Send Location"
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        self.GetHistory()
        self.Initialize()

        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    func Initialize() {
        
        //View initialize
        customizeView(containerView: self.headerView)
        self.headerView.layer.cornerRadius = 5
        self.headerView.layer.masksToBounds = true
        customizeView(containerView: self.compassView)
        self.compassView.layer.cornerRadius = 5
        self.compassView.layer.masksToBounds = true
        self.colorView.layer.cornerRadius = self.colorView.frame.height/2
        self.colorView.layer.masksToBounds = true
        self.compassImg.image = self.compassImg.image!.withRenderingMode(.alwaysTemplate)
        self.compassImg.tintColor = UIColor.init(netHex: 0xFFFFFF)
        //CLLocatoinManager initialize
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        self.currentLocation = CLLocation(latitude: SharedManager.sharedInstance.currentlant, longitude: SharedManager.sharedInstance.currentlongi)
        self.centerMapOnLocation(location: self.currentLocation)
        self.GetAddressFromLocation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        let rightButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MainViewController.GotoHistory))
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    func GetAddressFromLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (placeMark, err) in
            DispatchQueue.main.async {
                guard let pm = placeMark?.last, let locationName = pm.name else {
                    self.addresslabel.text = "N/A"
                    return }
                self.addresslabel.text = locationName
            }
        }
    }
    
    func GetHistory() {
        if !first {
            SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        }
        self.requestArray.removeAll()
        
        //MARK: History downloading from Firebase
        self.ref.child("P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/RequestInfo").observe(DataEventType.value, with: { snapshot in
            
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                print(dict)
                self.requestArray.append(dict)
            }
            SharedManager.sharedInstance.requestInfos = self.requestArray
            
            SKActivityIndicator.dismiss()
            
            if self.first {
                print("++++++++++++++++++++++")
                let latitude = self.requestArray.last!["lat"] as! String
                let longitude = self.requestArray.last!["lon"] as! String
                self.GeneratingNotification(lat: latitude, lon: longitude)
            }else {
                SKActivityIndicator.dismiss()
                self.first = true
            }
        })
        
    }
    
    func GeneratingNotification(lat: String, lon: String) {
        //MARK: Local Notification.
        let notification = UNMutableNotificationContent()
        notification.title = "P2P Location!"
        notification.subtitle = "You just received location request."
        notification.userInfo = ["lat": lat, "lon": lon]
        notification.body = ""
        
        notification.sound = UNNotificationSound.default()
        
        //To Present image in notification
        if let path = Bundle.main.path(forResource: "logo", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "localNotification", url: url, options: nil)
                notification.attachments = [attachment]
            } catch {
                print("attachment not found.")
            }
        }
        
        let identity = "p2plocation"
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identity, content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc func GotoHistory() {
        performSegue(withIdentifier: "history", sender: self)
    }
   
    func centerMapOnLocation(location: CLLocation) {
        
        let camera = MKMapCamera()
        camera.altitude = 1000.0
        camera.pitch = 0
        camera.heading = 0
        camera.centerCoordinate = location.coordinate
        
        self.mapView.setCamera(camera, animated: true)
    }
    @IBAction func CompassAction(_ sender: UIButton) {
        
        self.mapView.setCenter(self.currentLocation.coordinate, animated: true)
    }
    
    @IBAction func PickLocation(_ sender: UIButton) {
        performSegue(withIdentifier: "pincode", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pincode" {
            let pincode = segue.destination as! PinCodeViewController
            print("+_________ \(self.currentLocation.coordinate.latitude)")
            print("+_________ \(self.currentLocation.coordinate.longitude)")
            pincode.sendLocation = self.currentLocation
        }else if segue.identifier == "history" {
            let _ = segue.destination as! RequestInfoHistoryViewController
        }
    }
    
}

extension MainViewController: MKMapViewDelegate {
    
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        mapView.showsUserLocation = true
        self.GetAddressFromLocation()
//        self.centerMapOnLocation(location: self.currentLocation)
        
    }
}

extension MainViewController: SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}

