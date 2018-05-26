//
//  LeftViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/16/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Firebase
import FirebaseAuth
import SKActivityIndicatorView

enum LeftMenu: Int {
    case main = 0
    case booking
    case setting
    case aboutus
    case privacypolicy
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController: UIViewController, LeftMenuProtocol {
    
    var mainViewController: UIViewController!
    var bookingViewController: UIViewController!
    var settingViewController: UIViewController!
    var aboutUsViewController: UIViewController!
    var privacyPolicyViewController: UIViewController!
    var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookingViewController = storyboard.instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
        self.bookingViewController = UINavigationController(rootViewController: bookingViewController)
        
        let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.settingViewController = UINavigationController(rootViewController: settingViewController)
        
        let aboutUsViewController = storyboard.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
        self.aboutUsViewController = UINavigationController(rootViewController: aboutUsViewController)
        
        let privacyPolicyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        self.privacyPolicyViewController = UINavigationController(rootViewController: privacyPolicyViewController)
        
        self.imageHeaderView = ImageHeaderView.loadNib()
        self.view.addSubview(self.imageHeaderView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    @IBAction func GotoHome(_ sender: UIButton) {
        
        if let menu = LeftMenu(rawValue: 0) {
            self.changeViewController(menu)
        }
    }
    
    @IBAction func GotoBooking(_ sender: UIButton) {
        if let menu = LeftMenu(rawValue: 1) {
            self.changeViewController(menu)
        }
    }
    
    @IBAction func GotoSetting(_ sender: UIButton) {
        
        if let menu = LeftMenu(rawValue: 2) {
            self.changeViewController(menu)
        }
    }
    
    @IBAction func GotoAboutUs(_ sender: UIButton) {
        
        if let menu = LeftMenu(rawValue: 3) {
            self.changeViewController(menu)
        }
    }
    
    @IBAction func GotoPrivacyPolicy(_ sender: UIButton) {
        
        if let menu = LeftMenu(rawValue: 4) {
            self.changeViewController(menu)
        }
    }
    
    @IBAction func LogOutAction(_ sender: UIButton) {
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
    
    //MARK: Show Alert View Controller
    func showAlert(_ title: String, message: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .booking:
            self.slideMenuController()?.changeMainViewController(self.bookingViewController, close: true)
        case .setting:
            self.slideMenuController()?.changeMainViewController(self.settingViewController, close: true)
        case .aboutus:
            self.slideMenuController()?.changeMainViewController(self.aboutUsViewController, close: true)
        case .privacypolicy:
            self.slideMenuController()?.changeMainViewController(self.privacyPolicyViewController, close: true)
        }
    }
}


