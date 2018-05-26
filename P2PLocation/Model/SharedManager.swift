//
//  SharedManager.swift
//  P2PLocation
//
//  Created by MyCom on 5/17/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class SharedManager {
    
    static let sharedInstance = SharedManager()
    
    var email: String = ""
    var userID: String = ""
    var currentLoc: CLLocationCoordinate2D!
    var currentlant: CLLocationDegrees!
    var currentlongi: CLLocationDegrees!
    var requestInfos: [NSDictionary] = [NSDictionary]()
    var fakeLoc: CLLocation!
}
