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
    private var currentUser: User = User.current()
    private var sharedPosts: [Post] = []
    private let duration: NSTimeInterval = 0.2
    private let delay: NSTimeInterval = 0
    
    // MARK: UITableViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Navigation Bar
        self.navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 18)
        ]
        
        // Configure Table
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Self Loading Title
        self.title = "Loading..."
        
        // Get Shared Posts
        self.currentUser.getSharedPosts { (posts) -> Void in
            if !posts.isEmpty {
                self.sharedPosts = posts
                self.tableView.reloadData()
                self.title = "Shared Drops"
            } else {
                self.title = "No Shared Drops"
                
            }
        }
    }
    
    // MARK: IBAction Methods
    @IBAction func shareExit(sender: UIBarButtonItem) {
        self.navigationController.popViewControllerAnimated(false)
    }
    
    // UITableViewController Methods
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.sharedPosts.count
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 250
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> CardTableViewCell! {
        var post = self.sharedPosts[indexPath.row]
        var cell: CardTableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? CardTableViewCell
        
        if cell == nil {
            cell = CardTableViewCell(reuseIdentifier: self.cellIdentifier)
        }
        
        cell.backgroundImageView.alpha = 0
        cell.backgroundImageView.image = UIImage()
        
        post.getImage({ (image) -> Void in
            UIView.animateWithDuration(self.duration, delay: self.delay, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.backgroundImageView.alpha = 1
                cell.backgroundImageView.image = image
            }, completion: nil)
        })
        
        // Coloring Content With Names
        var contentAttr = NSMutableAttributedString()
        
        for block in post.content {
            var blockAttrString = NSMutableAttributedString(string: block["message"] as String)
            
            if block["color"] as Bool {
                blockAttrString.addAttribute(NSForegroundColorAttributeName,
                    value: UIColor(red:0.31, green:0.95, blue:1, alpha:1), range: NSMakeRange(0, blockAttrString.length))
            }
            
            contentAttr.appendAttributedString(blockAttrString)
        }
        
        cell.content.attributedText = contentAttr
        
        return cell
    }
}
