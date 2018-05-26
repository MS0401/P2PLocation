//
//  ChangeEmailViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/20/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView

class ChangeEmailViewController: UIViewController {
    
    var email: String!
    var accounts: [Account] = [Account]()

    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    @IBOutlet var headerview: UIView!
    @IBOutlet var emailtxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Change Email"
        self.emailtxt.text = self.email
//        customizeView(containerView: self.headerview)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
    }

    @IBAction func ChangeEmail(_ sender: UIButton) {
        
        //Displaying SKActivityIndicator progress view.
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        
        if let user = Auth.auth().currentUser {
            
            user.updateEmail(to: self.emailtxt.text!, completion: { (error) -> Void in
                
                if error != nil {
                    SKActivityIndicator.dismiss()
                    self.showAlert("Error", message: (error?.localizedDescription)!)
                }else {
                    self.Uploading()
                }
                
            })
        }else {
            SKActivityIndicator.dismiss()
            self.showAlert("Error", message: "There are no any user")
        }
    }
    
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //MARK: Firebase uploading function/// ******** important ********
        
        let phone = self.accounts[0].countryCode + self.accounts[0].phoneNumber
        
        let dataInformation: NSDictionary = ["imageURL": self.accounts[0].imgURL, "firstname": self.accounts[0].firstname, "lastname": self.accounts[0].lastname, "userEmail": self.emailtxt.text!, "userPassword": self.accounts[0].userPassword,"countryCode": self.accounts[0].countryCode, "phoneNumber": phone]
        
        
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/Profile/profile/": dataInformation] // profile Image uploading
        
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
        
        let usersID: NSDictionary = ["userID": SharedManager.sharedInstance.userID, "email": self.emailtxt.text!]
        
        let uuid = UUID().uuidString
        
        // MARK: add firebase child node
        let child = ["/P2PLocation/UsersID/\(uuid)": usersID]
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                print("Successfully registered and uploaded your data.")
                SKActivityIndicator.dismiss()
                self.showAlert("Success", message: "You have changed new email successfully!")
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
