//
//  PrivacyPolicyViewController.swift
//  P2PLocation
//
//  Created by MyCom on 5/16/18.
//  Copyright © 2018 MyCom. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Privacy Policy"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }

}
