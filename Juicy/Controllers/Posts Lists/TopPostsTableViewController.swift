//
//  TopTenTableViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/24/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit

class TopPostsTableViewController: UITableViewController {

    // MARK: Instance Variables
    private var cellIdentifier = "cell"
    private var cellHeight: CGFloat!
    private var myPosts: [Post] = []
    private let duration: NSTimeInterval = 0.2
    private let delay: NSTimeInterval = 0
    
    // MARK: UITableViewController Overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Track Event
        Track.event("Top Posts Controller: Viewed")
        
        // Configure Navigation Bar
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 18) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font
            ]
        }
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadMyPosts"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Configure Table
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Set Default Height
        self.cellHeight = self.tableView.frame.height/2
        
        // Self Loading Title
        self.title = "Loading..."
        
        // Get Shared Posts
        self.reloadMyPosts()
    }
    
    // MARK: Instance Methods
    func reloadMyPosts() {
        Post.topPosts(limit: 10) { (posts) -> Void in
            if !posts.isEmpty {
                self.title = "Juiciest Posts"
            } else {
                self.title = "No Posts Found"
            }
            
            self.myPosts = posts
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            // Track Event
            Track.event("Top Posts Controller: Reloaded Posts", data: [
                "posts": posts.count.description
            ])
        }
    }
    
    // MARK: IBAction Methods
    @IBAction func backButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    // UITableViewController Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.height/2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var post = self.myPosts[indexPath.row]
        var cell: CardTableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? CardTableViewCell
        
        if cell == nil {
            cell = CardTableViewCell(reuseIdentifier: self.cellIdentifier, width: self.view.frame.width, height: self.cellHeight)
        }
        
        cell.setSeparator(post != self.myPosts.first)
        cell.setContent(post, standing: indexPath.row + 1)
        
        return cell
    }
}
