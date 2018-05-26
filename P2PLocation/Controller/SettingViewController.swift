//
//  SettingViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/16/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView
import Photos
import PhotosUI

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var middleView: UIView!
    @IBOutlet var profileimage: UIImageView!
    @IBOutlet var header_fullname: UILabel!
    @IBOutlet var header_phonnumber: UILabel!
    @IBOutlet var fullname: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var mobilenumber: UILabel!
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var uniqueID: UILabel!
    
    var accounts: [Account] = [Account]()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var dictArray: [NSDictionary] = [NSDictionary]()
    var password: String = ""
    var countrycode: String = ""
    var phonenumber: String = ""
    
    // ImagePickerController property
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Setting"
        self.Initialize()
    }
    
    func Initialize() {
        self.profileimage.layoutIfNeeded()
        self.profileimage.layer.cornerRadius = self.profileimage.frame.height/2
        self.profileimage.layer.masksToBounds = true
        
        self.uniqueID.text = SharedManager.sharedInstance.userID
        customizeView(containerView: self.headerView)
        customizeView(containerView: self.middleView)
        customizeButton(btn: self.logoutBtn)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        //MARK: History downloading from Firebase
        self.ref.child("P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/Profile").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                let profile = Account(dictionary: dict)
                self.accounts.append(profile)
            }
            
            for item in self.accounts {
                
                if item.userEmail == SharedManager.sharedInstance.email {
                    
                    self.profileimage.image = item.image
                    self.header_fullname.text = item.firstname + " " + item.lastname
                    self.header_phonnumber.text = item.countryCode + item.phoneNumber
                    self.fullname.text = item.firstname + " " + item.lastname
                    self.email.text = item.userEmail
                    self.mobilenumber.text = item.countryCode + item.phoneNumber
                    self.countrycode = item.countryCode
                    self.phonenumber = item.phoneNumber
                    self.password = item.userPassword
                }
            }
            SKActivityIndicator.dismiss()
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    @IBAction func ChangeProfileImage(_ sender: UIButton) {
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
    
    @IBAction func LogOut(_ sender: UIButton) {
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                
                SKActivityIndicator.dismiss()
                // create viewController code...
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window!.rootViewController = viewController
                
            } catch let error as NSError {
                SKActivityIndicator.dismiss()
                print(error.localizedDescription)
                self.showAlert("Error", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func ChangeName(_ sender: UIButton) {
        performSegue(withIdentifier: "changename", sender: self)
    }
    
    @IBAction func ChangeEmail(_ sender: UIButton) {
        performSegue(withIdentifier: "changeemail", sender: self)
    }
    
    @IBAction func ChangeMobileNumber(_ sender: UIButton) {
        performSegue(withIdentifier: "changemobile", sender: self)
    }
    
    @IBAction func ChangePassword(_ sender: UIButton) {
        performSegue(withIdentifier: "changepassword", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changename" {
            let changename = segue.destination as! ChangeNameViewController
            changename.firstname = self.fullname.text!.components(separatedBy: " ")[0]
            changename.lastname = self.fullname.text!.components(separatedBy: " ")[1]
            changename.accounts = self.accounts
        }else if segue.identifier == "changeemail" {
            let changeemail = segue.destination as! ChangeEmailViewController
            changeemail.email = self.email.text!
            changeemail.accounts = self.accounts
        }else if segue.identifier == "changemobile" {
            let changemobile = segue.destination as! ChangeMobileNumberController
            changemobile.countrycode = self.countrycode
            changemobile.phonenumber = self.phonenumber
            changemobile.accounts = self.accounts
        }else if segue.identifier == "changepassword" {
            let changepassword = segue.destination as! ChangePasswordViewController
            changepassword.password = self.password
            changepassword.accounts = self.accounts
        }
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
            self.profileimage.backgroundColor = UIColor.clear
            self.profileimage.image = pickedImage
                        
        }
        picker.dismiss(animated: true, completion: nil)
        self.Uploading()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //Displaying SKActivityIndicator progress view.
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        //MARK: Firebase uploading function/// ******** important ********
        
        //getting image URL from library or photoAlbum.
        var data: NSData = NSData()
        if let image = self.profileimage.image {
            
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        }
        
        let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        let phone = self.accounts[0].countryCode + self.accounts[0].phoneNumber
        
        let dataInformation: NSDictionary = ["imageURL": imageURL, "firstname": self.accounts[0].firstname, "lastname": self.accounts[0].lastname, "userEmail": self.accounts[0].userEmail, "userPassword": self.accounts[0].userPassword,"countryCode": self.accounts[0].countryCode, "phoneNumber": phone]
        
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/Profile/profile/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                SKActivityIndicator.dismiss()
                self.showAlert("Success", message: "You have changed your name successfully!")
            }else {
                SKActivityIndicator.dismiss()
                self.showAlert("Error!", message: (error?.localizedDescription)!)
            }
        })
    }
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
}
