//
//  LoginViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/14/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import Firebase
import SKActivityIndicatorView
import CoreLocation

class LoginViewController: UIViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var container: UIView!
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var dictArray: [NSDictionary] = [NSDictionary]()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        //MARK: keeping inputed user's email
        self.retrieveAccountInfo()

        self.container.layer.cornerRadius = 5
        customizeView(containerView: self.container)
        self.loginBtn.layer.cornerRadius = 5
        customizeButton(btn: self.loginBtn)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.TapView(gestureRecognizer:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    //Keep inputed email
    func retrieveAccountInfo() {
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "email") != nil {
            
            self.email.text = defaults.string(forKey: "email")
            self.password.text = defaults.string(forKey: "password")
            
        }
    }
    
    @objc func TapView(gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func LoginAction(_ sender: UIButton) {
        
        let email = self.email.text!
        let password = self.password.text!
        
        
        let defaults = UserDefaults.standard
        
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else {
            
            //Displaying SKActivityIndicator progress view.
            SKActivityIndicator.show("Loading...", userInteractionStatus: false)
            
            self.FirebaseEmailLogin()
        }
        
    }
    
    func FirebaseEmailLogin() {
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            
            if error == nil {
                
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                
                //MARK: History downloading from Firebase
                self.ref.child("P2PLocation/UsersID").observeSingleEvent(of: DataEventType.value, with: { snapshot in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let dict = child.value as! NSDictionary
                        print(dict)
                        self.dictArray.append(dict)
                        
                    }
                    
                    if self.dictArray.count == 0 {
                        SKActivityIndicator.dismiss()
                        self.showAlert("Warning!", message: "Have you ever logged in?. Please sign up!")
                    }else {
                        
                        for item in self.dictArray {
                            
                            let tempEmail = item["email"] as! String
                            if tempEmail == self.email.text! {
                                
                                let userid = item["userID"] as! String
                                SharedManager.sharedInstance.userID = userid
                                SharedManager.sharedInstance.email = self.email.text!
                                SKActivityIndicator.dismiss()
                                self.createMenuView()
                            }
                        }
                    }
                    
                })
            } else {
                
                //Tells the user that there is an error and then gets firebase to tell them the error
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                SKActivityIndicator.dismiss()
            }
        }
    }
    
    fileprivate func createMenuView() {
        
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
        
        leftViewController.mainViewController = nvc       

        let slideMenuController = ExSlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = slideMenuController
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}

extension LoginViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        SharedManager.sharedInstance.currentLoc = locValue
        SharedManager.sharedInstance.currentlant = locValue.latitude
        SharedManager.sharedInstance.currentlongi = locValue.longitude
    }
}
