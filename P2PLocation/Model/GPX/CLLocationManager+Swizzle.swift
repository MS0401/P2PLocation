//
//  CLLocationManager+Swizzle.swift
//  P2PLocation
//
//  Created by MyCom on 5/18/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import Foundation
import MapKit

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    
   
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        
        let didAddMethod = class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension CLLocationManager {
    static let classInitStart: Void = {
        let originalSelector = #selector(CLLocationManager.startUpdatingLocation)
        let swizzledSelector = #selector(swizzledStartLocation)
        swizzling(CLLocationManager.self, originalSelector, swizzledSelector)        
    }()
    
    static let classInitStop: Void = {
        let originalStopSelector = #selector(CLLocationManager.stopUpdatingLocation)
        let swizzledStopSelector = #selector(swizzledStopLocation)
        swizzling(CLLocationManager.self, originalStopSelector, swizzledStopSelector)
    }()
    
    @objc func swizzledStartLocation() {
        print("swizzled start location")
        if !MockCLLocationManager.shared.isRunning {
            MockCLLocationManager.shared.startMocks(usingGpx: "TysonCorner")
        }
        MockCLLocationManager.shared.delegate = self.delegate
        MockCLLocationManager.shared.startUpdatingLocation()
                
    }
    
    @objc func swizzledStopLocation() {
        print("swizzled stop location")
        MockCLLocationManager.shared.stopUpdatingLocation()
        
    }
    
    @objc func swizzedRequestLocation() {
        print("swizzled request location")
        MockCLLocationManager.shared.requestLocation()
        
    }
}
