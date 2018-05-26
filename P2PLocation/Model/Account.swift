//
//  Account.swift
//  TrackingTest
//
//  Created by admin on 9/7/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Account {
    
    var firstname: String
    var lastname: String
    var userEmail: String
    var userPassword: String
    var countryCode: String
    var phoneNumber: String
    var image: UIImage
    var imgURL: String
    
    init() {
        
        self.firstname = ""
        self.lastname = ""
        self.userEmail = ""
        self.userPassword = ""
        self.countryCode = ""
        self.phoneNumber = ""
        self.image = UIImage.init()
        self.imgURL = ""
    }
    
    init(firstName: String, lastName: String, useremail: String, userpassword: String, image: UIImage, imgURL: String, countrycode: String, phonenumber: String) {
        
        self.firstname = firstName
        self.lastname = lastName
        self.userEmail = useremail
        self.userPassword = userpassword
        self.countryCode = countrycode
        self.phoneNumber = phonenumber
        self.image = image
        self.imgURL = imgURL
    }
    
    convenience init(dictionary: NSDictionary) {
        
        
        let firstname = dictionary["firstname"] as! String
        let lastname = dictionary["lastname"] as! String
        let useremail = dictionary["userEmail"] as! String
        let userpassword = dictionary["userPassword"] as! String
        let countrycode = dictionary["countryCode"] as! String
        let phonenumber = dictionary["phoneNumber"] as! String
        let imageURL = dictionary["imageURL"] as! String
        
        //Convert from String into Image.
        let decodeData = NSData(base64Encoded: imageURL, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let image = UIImage(data: decodeData! as Data, scale: 1.0)
        
        self.init(firstName: firstname, lastName: lastname, useremail: useremail, userpassword: userpassword, image: image!, imgURL: imageURL, countrycode: countrycode, phonenumber: phonenumber)
    }
    
}
