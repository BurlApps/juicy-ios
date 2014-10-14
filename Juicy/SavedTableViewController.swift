//
//  SavedTableViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/28/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class SavedTableViewController: UITableViewController {
    
    // MARK: Instance Variables
    private var cellIdentifier = "cell"
    private var cellHeight: CGFloat!
    private var user: User = User.current()
    private var sharedPosts: [Post] = []
    private let duration: NSTimeInterval = 0.2
    private let delay: NSTimeInterval = 0
    
    // MARK: UITableViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Track Event
        Track.event("Saved Posts Controller: Viewed")
        
        // Configure Navigation Bar
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 18)
        ]
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadSharedPosts"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Configure Table
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Set Default Height
        self.cellHeight = self.tableView.frame.height/2
        
        // Self Loading Title
        self.title = "Loading..."
        
        // Get Shared Posts
        self.reloadSharedPosts()
    }
    
    // MARK: Instance Methods
    func reloadSharedPosts() {
        self.user.getSharedPosts { (posts) -> Void in
            if !posts.isEmpty {
                self.title = "Shared Posts"
            } else {
                self.title = "No Shared Posts"
            }
            
            self.sharedPosts = posts
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            // Track Event
            Track.event("Saved Posts Controller: Reloaded Posts", data: [
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
        return self.sharedPosts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.height/2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var post = self.sharedPosts[indexPath.row]
        var cell: CardTableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? CardTableViewCell
        
        if cell == nil {
            cell = CardTableViewCell(reuseIdentifier: self.cellIdentifier, width: self.view.frame.width, height: self.cellHeight)
        }
        
        cell.setSeparator(post != self.sharedPosts.first)
        cell.setContent(post, standing: nil)

        return cell
    }
}
