//
//  ShareTableViewController.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/21/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class ShareViewController: UIViewController, THContactPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Instance Variables
    var aboutPost: Post!
    private var user: User = User.current()
    private var contactPicker: THContactPickerView!
    private var tableView: UITableView!
    private var contacts: NSArray = []
    private var filteredContacts: NSArray = []
    private var privateSelectedContacts: NSMutableArray = []
    private let kPickerViewHeight: CGFloat = 100.0
    private let THContactPickerContactCellReuseID = "THContactPickerContactCell"
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track Event
        Track.event("Share Controller: Viewed")
        
        // Additional Setup
        if self.respondsToSelector(Selector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.Bottom|UIRectEdge.Left|UIRectEdge.Right
        }
        
        // TODO: Change to real contacts
        var contacts = Contacts()
        
        dispatch_async(dispatch_get_main_queue(), {
            contacts.getContacts { (contacts) -> Void in
                var contactList = NSMutableArray()
                
                for contact in contacts {
                    for phone in contact.phones {
                        var contactDict = NSMutableDictionary()
                        contactDict.setObject(contact.name, forKey: "name")
                        contactDict.setObject(phone.name, forKey: "group")
                        contactDict.setObject(phone.phone, forKey: "phone")
                        contactList.addObject(contactDict)
                    }
                }
                
                self.contacts = contactList as NSArray
                self.tableView.reloadData()
            }
        })
        
        // Initialize and add Contact Picker View
        self.contactPicker = THContactPickerView(frame: CGRectMake(0, 0, self.view.frame.width, self.kPickerViewHeight))
        self.contactPicker.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin|UIViewAutoresizing.FlexibleWidth
        self.contactPicker.delegate = self
        self.contactPicker.setPlaceholderLabelText("Who do we share this post with?")
        self.contactPicker.setPromptLabelText("To:")
        self.contactPicker.limitToOne = false
        self.contactPicker.layer.shadowColor = UIColor(red: 225.0/255.0, green: 226.0/255.0, blue: 228.0/255.0, alpha: 1).CGColor
        self.contactPicker.layer.shadowOffset = CGSizeMake(0, 2)
        self.contactPicker.layer.shadowOpacity = 1
        self.contactPicker.layer.shadowRadius = 1
        self.view.addSubview(self.contactPicker)

        // Fill the rest of the view with the table view
        var tableFrame = CGRectMake(0, self.contactPicker.frame.height, self.view.frame.width, self.view.frame.height - self.contactPicker.frame.height)
        self.tableView = UITableView(frame: tableFrame, style: UITableViewStyle.Plain)
        self.tableView.autoresizingMask = UIViewAutoresizing.FlexibleHeight|UIViewAutoresizing.FlexibleWidth
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.insertSubview(self.tableView, belowSubview: self.contactPicker)
    }
    
    override func viewDidLayoutSubviews() {
        self.adjustTableFrame()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name:UIKeyboardDidHideNotification, object: nil)
        
        // Configure Navigation Bar
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 18) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font
            ]
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: IBActions
    
    @IBAction func closeShare(sender: UIBarButtonItem) {
        // Track Event
        Track.event("Share Controller: Canceled")
        
        // Pop to Parent View Controller
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func shareSend(sender: UIBarButtonItem) {
        if self.privateSelectedContacts.count != 0 {
            // Track Event
            Track.event("Share Controller: Sent", data: [
                "contacts": self.privateSelectedContacts.count.description
            ])
            
            // Send to Contacts
            self.navigationController?.popViewControllerAnimated(false)
            self.aboutPost.share(self.user, contacts: self.privateSelectedContacts)
        }
    }
    
    // MARK: Instance Methods
    func getFilteredContacts() -> NSArray {
        if self.filteredContacts.count == 0 {
            self.filteredContacts = self.contacts
        }
        
        return self.filteredContacts
    }
    
    func selectedContacts() -> NSArray {
        return self.privateSelectedContacts.copy() as NSArray
    }
    
    func selectedCount() -> Int {
        return self.privateSelectedContacts.count
    }
    
    func getSelectedContacts() -> NSArray {
        return self.privateSelectedContacts.copy() as NSArray
    }
    
    func adjustTableViewInsetTop(topInset: CGFloat, bottomInset: CGFloat) {
        self.tableView.contentInset = UIEdgeInsetsMake(topInset, self.tableView.contentInset.left, bottomInset, self.tableView.contentInset.right)
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }

    func adjustTableFrame() {
        let yOffset = self.contactPicker.frame.origin.y + self.contactPicker.frame.size.height
        let tableFrame = CGRectMake(0, yOffset, self.view.frame.width, self.view.frame.height - yOffset)
        self.tableView.frame = tableFrame
    }

    func adjustTableViewInsetTop(topInset: CGFloat) {
        self.adjustTableViewInsetTop(topInset, bottomInset: self.tableView.contentInset.bottom)
    }

    func adjustTableViewInsetBottom(bottomInset: CGFloat) {
        self.adjustTableViewInsetTop(self.tableView.contentInset.top, bottomInset: bottomInset)
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        cell.textLabel.attributedText = self.titleForRowAtIndexPath(indexPath)
        cell.textLabel.numberOfLines = 2
    }

    func newFilteringPredicateWithText(text: String) -> NSPredicate {
        return NSPredicate(format: "name contains[cd] %@", argumentArray: [text])
    }

    func titleForRowAtIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        let contact = self.getFilteredContacts()[indexPath.row] as NSDictionary
        let name = contact["name"] as String
        let group = contact["group"] as String
        let phone = contact["phone"] as String
        var contactName = NSMutableAttributedString(string: "\(name)\n")
        var contactGroup = NSMutableAttributedString(string: "\(group)  \(phone)")
        
        contactName.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(0, contactName.length))
        contactName.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue", size: 16)!, range: NSMakeRange(0, contactName.length))
        
        contactGroup.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(0, contactGroup.length))
        contactGroup.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: NSMakeRange(0, group.utf16Count))
        
        contactName.appendAttributedString(contactGroup)
        
        return contactName
    }
    
    func didChangeSelectedItems() {
    
    }

    // MARK: UITableView Delegate and Datasource functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getFilteredContacts().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.THContactPickerContactCellReuseID) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: self.THContactPickerContactCellReuseID)
        }
        
        self.configureCell(cell, indexPath: indexPath)
        
        if self.privateSelectedContacts.containsObject(self.getFilteredContacts()[indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        let contact = self.getFilteredContacts()[indexPath.row] as NSDictionary
        let contactName = contact["name"] as String
        
        if self.privateSelectedContacts.containsObject(contact) {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            self.privateSelectedContacts.removeObject(contact)
            self.contactPicker.removeContact(contact)
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.privateSelectedContacts.addObject(contact)
            self.contactPicker.addContact(contact, withName: contactName)
        }
        
        self.filteredContacts = self.contacts
        self.didChangeSelectedItems()
        self.tableView.reloadData()
    }

    // MARK: THContactPickerTextViewDelegate
    func contactPickerTextViewDidChange(textViewText: String!) {
        if textViewText == "" {
            self.filteredContacts = self.contacts
        } else {
            let predicate = self.newFilteringPredicateWithText(textViewText)
            self.filteredContacts = self.contacts.filteredArrayUsingPredicate(predicate)
        }
        
        self.tableView.reloadData()
    }
    
    func contactPickerDidResize(contactPickerView: THContactPickerView!) {
        if self.tableView != nil {
            var frame = self.tableView.frame
            frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y
            self.tableView.frame = frame
        }
    }
    
    func contactPickerDidRemoveContact(contact: AnyObject!) {
        self.privateSelectedContacts.removeObject(contact)
        
        let index = self.contacts.indexOfObject(contact)
        var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        if cell != nil {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            self.didChangeSelectedItems()
        }
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let rect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue).CGRectValue()
        let kbRect = self.view.convertRect(rect, fromView: self.view.window)
        self.adjustTableViewInsetBottom(self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y)
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.keyboardDidShow(notification)
    }
}
