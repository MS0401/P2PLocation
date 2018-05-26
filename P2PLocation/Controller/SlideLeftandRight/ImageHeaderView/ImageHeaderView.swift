//
//  ImageHeaderCell.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/3/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit
import Firebase
import SKActivityIndicatorView

class ImageHeaderView : UIView {
    
    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var backgroundImage : UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var phoneNumber: UILabel!
    var accounts: [Account] = [Account]()
    
    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var dictArray: [NSDictionary] = [NSDictionary]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
//        self.backgroundColor = UIColor.init(netHex: 0xE0E0E0)
        self.profileImage.layoutIfNeeded()
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.height / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        
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
                    
                    self.profileImage.image = item.image
                    self.name.text = item.firstname + " " + item.lastname
                    self.phoneNumber.text = item.countryCode + item.phoneNumber
                    
                }
            }
            SKActivityIndicator.dismiss()
        })
    }
}
