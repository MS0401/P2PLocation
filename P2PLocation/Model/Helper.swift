//
//  Helper.swift
//  P2PLocation
//
//  Created by MyCom on 5/14/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import Foundation
import UIKit
import SKActivityIndicatorView

func SpinnerInitialize() {
    SKActivityIndicator.spinnerColor(UIColor.darkGray)
    SKActivityIndicator.statusTextColor(UIColor.black)
    let myFont = UIFont(name: "AvenirNext-DemiBold", size: 18)
    SKActivityIndicator.statusLabelFont(myFont!)
    SKActivityIndicator.spinnerStyle(.spinningFadeCircle)
}

enum PhotoSource {
    case library
    case camera
}

func customizeButton(btn:UIButton) {
    
    btn.layer.shadowColor = UIColor.init(netHex: 0xC5C5C5).cgColor
    btn.layer.shadowOpacity = 0.8
    btn.layer.shadowRadius = 12
    btn.layer.shadowOffset = CGSize(width: 1, height: 1)
}

func customizeView(containerView: UIView) {
    
    containerView.layer.shadowColor = UIColor.init(netHex: 0xC5C5C5).cgColor
    containerView.layer.shadowOpacity = 0.8
    containerView.layer.shadowRadius = 12
    containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
}

//MARK: extension UIColor(hexcolor)
extension UIColor {
    
    // Convert UIColor from Hex to RGB
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}
