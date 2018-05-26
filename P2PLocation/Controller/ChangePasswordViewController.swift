//
//  ChangePasswordViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/20/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView

class ChangePasswordViewController: UIViewController {

    
    @IBOutlet var oldpassword: UITextField!
    @IBOutlet var oldview: UIView!
    @IBOutlet var newpassword: UITextField!
    @IBOutlet var newview: UIView!
    @IBOutlet var confirmpassword: UITextField!
    @IBOutlet var confirmview: UIView!
    
    var password: String!
    var accounts: [Account] = [Account]()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Change Password"
//        customizeView(containerView: self.newview)
//        customizeView(containerView: self.oldview)
//        customizeView(containerView: self.confirmview)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
    }

    @IBAction func ChangePassword(_ sender: UIButton) {
        
        if self.oldpassword.text! == "" {
            self.showAlert("Error", message: "Please input your old password!")
        }else if self.newpassword.text! == "" {
            self.showAlert("Error", message: "Please input your new password!")
        }else if self.confirmpassword.text! == "" {
            self.showAlert("Error", message: "please input your confirm pasword!")
        }else if self.newpassword.text! != self.confirmpassword.text! {
            self.showAlert("Error", message: "Your new password was not confirmed. Please confirm your password")
        }else {
            //Displaying SKActivityIndicator progress view.
            SKActivityIndicator.show("Loading...", userInteractionStatus: false)
            
            if let user = Auth.auth().currentUser {
                user.updatePassword(to: self.newpassword.text!, completion: { (error) -> Void in
                    
                    if error != nil {
                        SKActivityIndicator.dismiss()
                        self.showAlert("Error", message: (error?.localizedDescription)!)
                        
                    }else {
                        self.Uploading()
                    }
                })
            }
            
        }
    }
    
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        let phone = self.accounts[0].countryCode + self.accounts[0].phoneNumber
        
        //MARK: Firebase uploading function/// ******** important ********
        
        let dataInformation: NSDictionary = ["imageURL": self.accounts[0].imgURL, "firstname": self.accounts[0].firstname, "lastname": self.accounts[0].lastname, "userEmail": self.accounts[0].userEmail, "userPassword": self.newpassword.text!,"countryCode": self.accounts[0].countryCode, "phoneNumber": phone]
        
        
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/Profile/profile/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                SKActivityIndicator.dismiss()
                self.showAlert("Success", message: "You have changed your password successfully!")
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
