//
//  LocationInfoReceiveController.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import CoreLocation

class LocationInfoReceiveController: UIViewController {
    
    var latitude: String = ""
    var longitude: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @IBAction func CancelApprove(_ sender: UIButton) {
        
        self.createMenuView()
    }
    
    @IBAction func ApproveFakeLocation(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "display", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "display" {
            if let control = segue.destination as? UINavigationController {
                if let contrl = control.topViewController as? DisplayFakeLocationController {
                    contrl.lat = self.latitude
                    contrl.lon = self.longitude
                    SharedManager.sharedInstance.fakeLoc = CLLocation(latitude: Double(self.latitude)!, longitude: Double(self.longitude)!)
                }
            }
        }
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
}
