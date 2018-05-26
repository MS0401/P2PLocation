//
//  RequestInfoHistoryViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Firebase

class RequestInfoHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!

    //MARK: Firebase initial path
    var ref: DatabaseReference!
    var requestArray: [NSDictionary] = [NSDictionary]()
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "History"
        
        //MARK: Appdelegate property
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        //MARK: base URL for Firebase database.
        self.ref = Database.database().reference()
        
        self.GetHistory()
    }
    
    func GetHistory() {
        
        self.requestArray.removeAll()
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        //MARK: History downloading from Firebase
        
        self.ref.child("P2PLocation/UsersData/\(SharedManager.sharedInstance.userID)/RequestInfo").observeSingleEvent(of: DataEventType.value, with: { snapshot in
            
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                print(dict)
                self.requestArray.append(dict)
            }
            
            SKActivityIndicator.dismiss()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let  vc =  self.navigationController?.viewControllers.filter({$0 is MainViewController}).first        
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! RequestInfoHistoryCell
        let request = requestArray[indexPath.row]
        cell.dateString.text = request["date"] as! String
        cell.latstr.text = request["lat"] as! String
        cell.lonstr.text = request["lon"] as! String
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
