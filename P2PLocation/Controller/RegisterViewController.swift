//
//  RegisterViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/14/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Firebase
import FirebaseAuth
import SKActivityIndicatorView
import CoreLocation

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var countryCode: UILabel!
    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var repassword: UITextField!
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var container: UIView!
    
    // ImagePickerController property
    let imagePicker = UIImagePickerController()
    
    var selectedCountry: Country!
    
    var appDelegate: AppDelegate!
    //MARK: Firebase initial path
    var ref: DatabaseReference!

    var userId: String!
    
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
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.profileImg.image = UIImage(named: "avatar_placeholder")
        self.profileImg.layer.borderWidth = 2
        self.profileImg.layer.borderColor = UIColor.init(netHex: 0x3493d5).cgColor
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height/2
        self.profileImg.layer.masksToBounds = true
        
        self.container.layer.cornerRadius = 5
        customizeView(containerView: self.container)
        self.registerBtn.layer.cornerRadius = 5
        customizeButton(btn: self.registerBtn)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.TapView(gestureRecognizer:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func TapView(gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
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
    
    @IBAction func RegisterAction(_ sender: UIButton) {
                
        if self.email.text == "" {
            self.showAlert("Warning!", message: "You didn't input your email. Please input your email.")
        }else if self.password.text == "" {
            self.showAlert("Warning!", message: "You didn't input your password. Please input your password.")
        }else if self.repassword.text == "" {
            self.showAlert("Warning!", message: "You didn't confirm your password. Please confirm your password.")
        }else if self.firstName.text == "" {
            self.showAlert("Warning!", message: "You didn't input your first name. Please input your first name.")
        }else if self.lastName.text == "" {
            self.showAlert("Warning!", message: "You didn't input your last name. Please input your last name.")
        }else if self.profileImg.image == UIImage(named: "avatar_placeholder.png") {
            self.showAlert("Warning!", message: "You didn't select your profile image. Please select your profile image.")
        }else if self.mobileNumber.text == "" {
            self.showAlert("Warning!", message: "You didn't input phone number. Please input phone number.")
        }else if self.password.text! != self.repassword.text! {
            self.showAlert("Warning!", message: "Confirm password is incorrect. Please confirm your password correctly.")
        }else {
            //Displaying SKActivityIndicator progress view.
            SKActivityIndicator.show("Loading...", userInteractionStatus: false)
            
            self.FirebaseEmailSignUp()
        }
        
    }

    @IBAction func GetCountryCode(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "country", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "country" {
            if let control = segue.destination as? UINavigationController {
                if let contrl = control.topViewController as? SRCountryPickerController {
                    contrl.countryDelegate = self
                }
            }
        }
    }
    
    func FirebaseEmailSignUp() {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            if error == nil {
                print("You have successfully signed up")
                
                //MARK: Uploading user information for chatting.
                user?.sendEmailVerification(completion: nil)
                
                let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
                let imageData = UIImageJPEGRepresentation(self.profileImg.image!, 0.1)
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
//                        let path = metadata?.downloadURL()?.absoluteString
                        
                        let values = ["firstname": self.firstName.text!, "lastname": self.lastName.text!, "email": self.email.text!, "password": self.password.text!]
                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                let userInfo = ["email" : self.email.text!, "password" : self.password.text!]
                                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                
                                self.Uploading()
                            }
                        })
                    }
                })
                
                
            } else {
                SKActivityIndicator.dismiss()
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //MARK: Firebase uploading function/// ******** important ********
        
        //getting image URL from library or photoAlbum.
        var data: NSData = NSData()
        if let image = self.profileImg.image {
            
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        }
        
        let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        let dataInformation: NSDictionary = ["imageURL": imageURL, "firstname": self.firstName.text!, "lastname": self.lastName.text!, "userEmail": self.email.text!, "userPassword": self.password.text!,"countryCode": self.countryCode.text!, "phoneNumber": self.mobileNumber.text!]
        
        //MARK: Getting unique id for user.
        let uuid = UUID().uuidString
        let idArray = uuid.components(separatedBy: "-")
        
        let capitalize = self.firstName.text!.uppercased()
        
        let subtxt = capitalize.index(capitalize.startIndex, offsetBy: 2)
        let uptxt = capitalize[...subtxt]
        let uniqueId = uptxt + "-" + idArray[1]
        self.userId = uniqueId
        
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(self.userId!)/Profile/profile/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                self.UploadingUsersID()
            }else {
                SKActivityIndicator.dismiss()
                self.showAlert("Error!", message: (error?.localizedDescription)!)
            }
        })
    }
    
    func UploadingUsersID() {
        
        let usersID: NSDictionary = ["userID": self.userId, "email": self.email.text!]
        
        let uuid = UUID().uuidString
        
        // MARK: add firebase child node
        let child = ["/P2PLocation/UsersID/\(uuid)": usersID]
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                print("Successfully registered and uploaded your data.")
                SKActivityIndicator.dismiss()
                self.createMenuView()                
            }else {
                SKActivityIndicator.dismiss()
                self.showAlert("Error!", message: (error?.localizedDescription)!)
            }
        })
    }
    
    @IBAction func GetPhoto(_ sender: UIButton) {
        
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.imagePicker.modalPresentationStyle = .popover
                self.imagePicker.sourceType = .photoLibrary// or savedPhotoAlbume
                self.imagePicker.allowsEditing = true
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: UIImagePickerContollerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImg.backgroundColor = UIColor.clear
            self.profileImg.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
 
}

extension RegisterViewController: CountrySelectedDelegate {
    
    func SRcountrySelected(countrySelected country: Country, flagImage: UIImage) {
        self.selectedCountry = country
        print("country selected  code \(self.selectedCountry.country_code), country name \(self.selectedCountry.country_name), dial code \(self.selectedCountry.dial_code)")
        self.countryCode.text =  "\(self.selectedCountry.dial_code)"
//        self.flagImage.image = flagImage
        
    }
    
}

extension RegisterViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        SharedManager.sharedInstance.currentLoc = locValue
        SharedManager.sharedInstance.currentlant = locValue.latitude
        SharedManager.sharedInstance.currentlongi = locValue.longitude
    }
}

