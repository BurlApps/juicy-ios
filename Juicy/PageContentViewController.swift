//
//  PageViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/26/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class PageContentViewController: UIViewController {
    
    // Instance Variables
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    // IBOutlets Variables
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.backgroundImageView.frame = self.view.frame
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.backgroundImageView.image = UIImage(named: self.imageFile)
        
        self.textLabel.text = self.titleText
        self.textLabel.frame = CGRectMake(25, 40, self.view.frame.width - 50, 50)
    }
}
