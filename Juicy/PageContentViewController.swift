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
    
    // Convience Constructor
    convenience init(frame: CGRect, index: Int) {
        self.init()
        
        self.view.frame = frame
        self.pageIndex = index
        
        self.view.backgroundColor = UIColor.clearColor()
        
        var backgroundImageView = UIImageView(frame: self.view.frame)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.contentMode = UIViewContentMode.Top
        backgroundImageView.image = UIImage(named: "HomePage\(index + 1)")
        self.view.addSubview(backgroundImageView)
    }
}
