//
//  PinCodeViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import CoreLocation
import PinCodeTextField
import Firebase
import SKActivityIndicatorView

class PinCodeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var pinCode: PinCodeTextField!

    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var dictArray: [NSDictionary] = [NSDictionary]()
    var sendLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pinCode.becomeFirstResponder()
        }
        
        self.pinCode.delegate = self
        self.pinCode.keyboardType = .default

        self.title = "Unique Code"
    }
    
    func GetAllUserPinCode(pincode: String, results: @escaping ((_ success: Bool) -> Void)) {
        
        //Displaying SKActivityIndicator progress view.
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        
        //MARK: History downloading from Firebase
        self.ref.child("P2PLocation/UsersID").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                print(dict)
                self.dictArray.append(dict)
                
            }
            
            if self.dictArray.count == 0 {
                results(false)
                SKActivityIndicator.dismiss()
                self.showAlert("Warning!", message: "There are no any user.")
            }else {
                
                for item in self.dictArray {
                    
                    let tempID = item["userID"] as! String
                    if tempID == pincode {
                        results(true)
                        return
                    }
                }
                
                SKActivityIndicator.dismiss()
                self.showAlertHandler(_title: "Incorrect ID!", message: "Inputed ID is incorrect. Please input again correctly")
            }
            
        })
    }
    
    func SendRequest(userId: String) {
        
        let latstr = "\(self.sendLocation.coordinate.latitude)"
        let lonstr = "\(self.sendLocation.coordinate.longitude)"
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let now = dateformatter.string(from: Date())
        
        let dataInformation: NSDictionary = ["lat": latstr, "lon": lonstr, "date": now]
        
//        let uuid = UUID().uuidString
        //MARK: add firebase child node
        let child1 = ["/P2PLocation/UsersData/\(userId)/RequestInfo/requestinfo/": dataInformation] // profile Image uploading
        
        //MARK: Write data to Firebase
        self.ref.updateChildValues(child1, withCompletionBlock: { (error, ref) in
            
            if error == nil {
                SKActivityIndicator.dismiss()
                self.showAlertHandler1(_title: "Success!", message: "You sent the request successfully!")
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
    func showAlertHandler(_title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            
            self.pinCode.text = ""
            self.pinCode.becomeFirstResponder()
        })
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        self.present(alertView, animated: true, completion: nil)
    }
    func showAlertHandler1(_title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            
//            self.performSegue(withIdentifier: "history", sender: self)
            self.navigationController?.popViewController(animated: true)
        })
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "history" {
            let _ = segue.destination as! RequestInfoHistoryViewController
        }
    }
}

extension PinCodeViewController: PinCodeTextFieldDelegate {
    @nonobjc func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    @nonobjc func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let value = textField.text ?? ""
        print("value changed: \(value)")
    }
    
    @nonobjc func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        
        if textField.text! == SharedManager.sharedInstance.userID {
            self.showAlertHandler(_title: "Warning!", message: "Inputed ID is your ID. Please input ID again correctly.")
        }else {
            self.GetAllUserPinCode(pincode: textField.text!, results: {(success) in
                
                if success {
                    print("Success")
                    self.SendRequest(userId: textField.text!)
                }
            })
        }
        
        return true
    }
    
    @nonobjc func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}

