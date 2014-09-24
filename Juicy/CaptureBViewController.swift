//
//  CaptureBViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/23/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class CaptureBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        PFAnalytics.trackEvent("Capture B Controller: Viewed")
    }
}
