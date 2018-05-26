//
//  DisplayFakeLocationController.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CountdownLabel

class DisplayFakeLocationController: UIViewController, MKMapViewDelegate {
    
    private let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addresslabel: UILabel!
    @IBOutlet var countdownlabel: CountdownLabel!
    
    var lat: String = ""
    var lon: String = ""
    var fakeLocation: CLLocation!
    var fakeCoordinate: CLLocationCoordinate2D!
    
    //MARK: FTLocationSimulator parts.
    var crumbs: CrumbPath!
    var crumbView: CrumbPathView!
    
//    #if FAKE_CORE_LOCATION
//        var locationManager: FTLocationSimulator!
//    #else
//        var locationManager: CLLocationManager!
//    #endif
//    var locationManager: FTLocationSimulator!
        
    var countdowntimer: Timer?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fakeLocation = CLLocation(latitude: Double(self.lat)!, longitude: Double(self.lon)!)
        mapView.delegate = self
        MockLocationConfiguration.GpxFileName = "TysonCorner"
        self.headerView.layer.cornerRadius = 10
        self.headerView.layer.masksToBounds = true
        customizeView(containerView: self.headerView)
        
//        self.locationManager.swizzedRequestLocation()
//        CLLocationManager.classInitStart
//        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.RepeatSwizzling), userInfo: nil, repeats: true)
        
//        #if DEBUG
//            self.mapView.simulateLocation(self.fakeLocation.coordinate)
//        #endif

        //MARK: Running Timer in background state continuously.
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        self.countdowntimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.RepeatFake), userInfo: nil, repeats: true)
        
        countdownlabel.setCountDownTime(minutes: 60*5)
        countdownlabel.timeFormat = "mm:ss"
        countdownlabel.textColor = UIColor.black
        countdownlabel.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.countdownlabel.isCounting {
            self.countdowntimer?.invalidate()
            self.locationManager.swizzledStopLocation()
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
    
    func GetAddressFromLocation(currentLoc: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLoc) { (placeMark, err) in
            DispatchQueue.main.async {
                guard let pm = placeMark?.last, let locationName = pm.name else {
                    self.addresslabel.text = "N/A"
                    return }
                self.addresslabel.text = locationName
            }
        }
    }
    
    @objc func RepeatSwizzling() {
        CLLocationManager.classInitStart
    }
    
    @objc func RepeatFake() {
//        MockCLLocationManager.shared.startMocks(usingGpx: "TysonCorner")
        if self.countdownlabel.isCounting {
            print("Now is counting")
        }else {
//            self.locationManager.requestWhenInUseAuthorization()
//            if CLLocationManager.locationServicesEnabled() {
//                self.locationManager.delegate = self
//                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                self.locationManager.startUpdatingLocation()
//            }
            
            self.countdownlabel.isHidden = true
            self.countdowntimer?.invalidate()
            self.locationManager.swizzledStopLocation()
            self.showAlertHandler(_title: "Time is done!", message: "Your time for fake location was expired.")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion.init(center: userLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.15, longitudeDelta: 0.15))
        
        print("current Location is +++++++++++++++\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        self.GetAddressFromLocation(currentLoc: userLocation.location!)
        mapView.setRegion(region, animated: true)
        
    }

    @IBAction func CancelMokingLocation(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlertHandler(_title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            
            self.createMenuView()
        })
        alertView.view.tintColor = UIColor(netHex: 0xFF7345)
        self.present(alertView, animated: true, completion: nil)
    }

}

extension DisplayFakeLocationController: CountdownLabelDelegate {
    func countdownFinished() {
        debugPrint("countdownFinished at delegate.")
    }
    
    func countingAt(timeCounted: TimeInterval, timeRemaining: TimeInterval) {
        debugPrint("time counted at delegate=\(timeCounted)")
        debugPrint("time remaining at delegate=\(timeRemaining)")
    }
    
}

extension DisplayFakeLocationController : CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        self.GetAddressFromLocation(currentLoc: locations.last!)
//
//        let location = locations.last?.coordinate
//        self.fakeCoordinate = location
//        let region = MKCoordinateRegion.init(center: self.fakeCoordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.15, longitudeDelta: 0.15))
//
//        print("current background Location is +++++++++++++++\(self.fakeCoordinate!.latitude), \(self.fakeCoordinate!.longitude)")
//        mapView.setRegion(region, animated: true)
//    }
    
    
    
}


























