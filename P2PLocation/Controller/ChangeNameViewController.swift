//
//  ChangeNameViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/20/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView

class ChangeNameViewController: UIViewController {
    
    @IBOutlet var fname: UITextField!
    @IBOutlet var lname: UITextField!
    @IBOutlet var headerView: UIView!
    
    var firstname: String!
    var lastname: String!
    var accounts: [Account] = [Account]()

    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Change Name"
        self.fname.text = self.firstname
        self.lname.text = self.lastname
//        customizeView(containerView: self.headerView)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
    }

    @IBAction func ChangeName(_ sender: UIButton) {
        
        self.Uploading()
    }
    
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //Displaying SKActivityIndicator progress view.
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        //MARK: Firebase uploading function/// ******** important ********
        
        let phone = self.accounts[0].countryCode + self.accounts[0].phoneNumber
        
        let dataInformation: NSDictionary = ["imageURL": self.accounts[0].imgURL, "firstname": self.fname.text!, "lastname": self.lname.text!, "userEmail": self.accounts[0].userEmail, "userPassword": self.accounts[0].userPassword,"countryCode": self.accounts[0].countryCode, "phoneNumber": phone]
        
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
