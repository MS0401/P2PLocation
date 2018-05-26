//
//  MockCLLocationManager.swift
//  P2PLocation
//
//  Created by MyCom on 5/18/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct MockLocationConfiguration {
    static var updateInterval = 0.5
    static var GpxFileName: String?
}

class MockCLLocationManager: CLLocationManager {
    private var parser: GpxParser?
    private var timer: Timer?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    private var locations: Queue<CLLocation>?
    private var _isRunning:Bool = false
    private var endbackgrond: Bool = false
    var updateInterval: TimeInterval = 0.1
    var isRunning: Bool {
        get {
            return _isRunning
        }
    }
    static let shared = MockCLLocationManager()
    private override init() {
        locations = Queue<CLLocation>()
    }
    func startMocks(usingGpx fileName: String) {
        if let fileName = MockLocationConfiguration.GpxFileName {
            parser = GpxParser(forResource: fileName, ofType: "gpx")
            parser?.delegate = self
            parser?.parse()
            
            if !endbackgrond {
                //MARK: Running Timer in background state continuously.
                backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
                })
                endbackgrond = true
            }
        }
    }
    func stopMocking() {
        self.stopUpdatingLocation()
    }
    private func updateLocation() {
//        if let location = locations?.dequeue() {
//            _isRunning = true
//            delegate?.locationManager?(self, didUpdateLocations: [SharedManager.sharedInstance.fakeLoc])
////            if let isEmpty = locations?.isEmpty(), isEmpty {
////                print("stopping at: \(location.coordinate)")
////                stopUpdatingLocation()
////            }
//        }
        delegate?.locationManager?(self, didUpdateLocations: [SharedManager.sharedInstance.fakeLoc])
    }
    override func startUpdatingLocation() {
        timer = Timer(timeInterval: updateInterval, repeats: true, block: {
            [unowned self](_) in
            self.updateLocation()
        })
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
    override func stopUpdatingLocation() {
        timer?.invalidate()
        _isRunning = false
        endbackgrond = false
    }
    override func requestLocation() {
//        if let location = locations?.peek() {
//            delegate?.locationManager?(self, didUpdateLocations: [location])
//        }
        delegate?.locationManager?(self, didUpdateLocations: [SharedManager.sharedInstance.fakeLoc])
    }
}

extension MockCLLocationManager: GpxParsing {
    func parser(_ parser: GpxParser, didCompleteParsing locations: Queue<CLLocation>) {
        self.locations = locations
//        print("fake info \(self.locations?.dequeue()?.coordinate)")
        self.startUpdatingLocation()
    }
}
