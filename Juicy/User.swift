//
//  User.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    
    // MARK: Instance Variables
    var username: String!
    var name: String!
    var displayName: String!
    var savedPosts: [Post]!
    var friendsList: [User]!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ user: PFUser, withRelations: Bool) {
        self.init()
        
        self.parse = user
        self.username = user["username"] as? String
        self.displayName = user["displayName"] as? String
        self.name = user["name"] as? String
        
        if withRelations {
            self.getSavedPosts(nil)
            self.getFriendsList(nil)
        }
    }
    
    // MARK: Instance Methods
    func setExtraInfo(callback: (() -> Void)?) {
        var meRequest = FBRequest.requestForMe()
        meRequest.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if !error && result != nil {
                let fbUser = result as FBGraphObject
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                
                self.parse["admin"] = false
                self.parse["email"] = fbUser["email"] as String
                self.parse["name"] = fbUser["name"] as String
                self.parse["displayName"] = fbUser["name"] as String
                self.parse["firstName"] = fbUser["first_name"] as String
                self.parse["gender"] = fbUser["gender"] as String
                
                if fbUser["birthday"] != nil {
                    self.parse["birthday"] = dateFormatter.dateFromString(fbUser["birthday"] as String)
                }
                
                self.parse.saveInBackground()
                callback?()
            } else if error {
                println(error)
            }
        })
        
        var friendsRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if !error && result != nil {
                var resultDict = result as NSDictionary
                var friendRelation = self.parse.relationForKey("friends")
                var queries: [PFQuery] = []
                
                for friend in resultDict["data"] as [FBGraphObject] {
                    var friendQuery = PFUser.query()
                    friendQuery.whereKey("name", equalTo: friend["name"])
                    queries.append(friendQuery)
                }
                
                var friendsQuery = PFQuery.orQueryWithSubqueries(queries)
                friendsQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in                    
                    if !error && !objects.isEmpty {
                        for object in objects as [PFUser] {
                            friendRelation.addObject(object)
                        }
                        
                        self.parse.saveInBackground()
                    } else if error {
                        println(error)
                    }
                })
            } else if error {
                println(error)
            }
        })
    }
    
    func getFriendsList(callback: ((users: [User]) -> Void)?) {
        var friends: [User] = []
        var query: PFQuery = (self.parse["friends"] as PFRelation).query()
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            if !error && !objects.isEmpty {
                for object in objects as [PFUser] {
                    let friend = User(object, withRelations: false)
                    friends.append(friend)
                }
                
                self.friendsList = friends
                callback?(users: friends)
            } else if error {
                println(error)
            }
        })
    }
    
    func getSavedPosts(callback: ((posts: [Post]) -> Void)?) {
        var posts: [Post] = []
        var query: PFQuery = (self.parse["savedPosts"] as PFRelation).query()
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            if !error && !objects.isEmpty {
                for object in objects as [PFObject] {
                    let post = Post(object)
                    posts.append(post)
                }
                
                self.savedPosts = posts
                callback?(posts: posts)
            } else if error {
                println(error)
            }
        })
    }
    
    // MARK: Class Methods
    class func current(withRelations: Bool) -> User {
        return User(PFUser.currentUser(), withRelations: withRelations)
    }
}
