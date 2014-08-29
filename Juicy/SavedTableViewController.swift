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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Get Shared Posts
        self.currentUser.getSharedPosts { (posts) -> Void in
            self.sharedPosts = posts
            self.tableView.reloadData()
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
        
        post.getImage({ (image) -> Void in
            cell.backgroundImageView.image = image
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
