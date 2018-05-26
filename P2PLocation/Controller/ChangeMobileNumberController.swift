//
//  ChangeMobileNumberController.swift
//  P2PLocation
//
//  Created by MyCom on 5/20/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView

class ChangeMobileNumberController: UIViewController {

    @IBOutlet var pnumber: UITextField!
    @IBOutlet var code: UILabel!
    @IBOutlet var headerView: UIView!
    var countrycode: String!
    var phonenumber: String!
    var accounts: [Account] = [Account]()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Change Mobile"
        self.code.text = self.countrycode
        self.pnumber.text = self.phonenumber
//        customizeView(containerView: self.headerView)
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
    }

    @IBAction func ChangePhoneNumber(_ sender: UIButton) {
        self.Uploading()
    }
    
    // MARK: Uploading User profile information to Firebase database.
    func Uploading() {
        
        //Displaying SKActivityIndicator progress view.
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        
        let phone = self.code.text! + self.pnumber.text!
        
        //MARK: Firebase uploading function/// ******** important ********
        
        let dataInformation: NSDictionary = ["imageURL": self.accounts[0].imgURL, "firstname": self.accounts[0].firstname, "lastname": self.accounts[0].lastname, "userEmail": self.accounts[0].userEmail, "userPassword": self.accounts[0].userPassword,"countryCode": self.accounts[0].countryCode, "phoneNumber": phone]
        
        
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/Profile/profile/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                SKActivityIndicator.dismiss()
                self.showAlert("Success", message: "You have changed your phone number successfully!")
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
