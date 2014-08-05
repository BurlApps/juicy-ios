//
//  FeedViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class FeedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation Bar
        self.navigationController.navigationBarHidden = false
        self.navigationController.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(red:0.96, green:0.33, blue:0.24, alpha:1),
            NSFontAttributeName: UIFont(name: "Balcony Angels", size: 36)
        ]
        self.navigationController.edgesForExtendedLayout = UIRectEdge.None
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Add Navigation Bottom Border
        var overlayView = UIView(frame: CGRectMake(0, self.navigationController.navigationBar.frame.height,
                                                    self.view.frame.width, 2))
        overlayView.backgroundColor = UIColor(red:0.92, green:0.89, blue:0.91, alpha:1)
        self.navigationController.navigationBar.addSubview(overlayView)
        
        // Setup View
        self.view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 1, alpha: 1)
    }

}
