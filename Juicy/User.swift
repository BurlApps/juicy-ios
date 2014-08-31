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
    var sharedPosts: [Post]!
    var friendsList: [User]!
    var registered: Bool!
    var terms: Bool!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ user: PFUser, withRelations: Bool = false) {
        self.init()
        
        self.parse = user
        self.username = user["username"] as? String
        self.displayName = user["displayName"] as? String
        self.name = user["name"] as? String
        self.terms = user["terms"] as? Bool
        self.registered = user["registered"] as? Bool
        
        if withRelations {
            self.getSharedPosts(nil)
            self.getFriendsList(nil)
        }
    }
    
    // MARK: Instance Methods
    func acceptedTerms() {
        self.parse["terms"] = true
        self.parse.saveInBackground()
    }
    
    func setExtraInfo(callback: (() -> Void)?) {
        var meRequest = FBRequest.requestForMe()
        meRequest.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil && result != nil {
                let fbUser = result as FBGraphObject
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                
                self.parse["email"] = fbUser["email"] as String
                self.parse["name"] = fbUser["name"] as String
                self.parse["firstName"] = fbUser["first_name"] as String
                self.parse["gender"] = fbUser["gender"] as String
                
                if fbUser["birthday"] != nil {
                    self.parse["birthday"] = dateFormatter.dateFromString(fbUser["birthday"] as String)
                }
                
                self.parse.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                    self.parse.fetch()
                })
                
                callback?()
            } else if error != nil {
                println(error)
            }
        })
        
        // Get Facebook Friends
        PFCloud.callFunctionInBackground("facebookFriends", withParameters: NSDictionary(), block: nil)
    }
    
    func getFriendsList(callback: ((users: [User]) -> Void)?) {
        if self.friendsList == nil {
            var friends: [User] = []
            var friendsRelation = self.parse["friends"] as PFRelation
            var query = friendsRelation.query()
            
            query.cachePolicy = kPFCachePolicyNetworkElseCache
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
                if error == nil {
                    for object in objects as [PFUser] {
                        let friend = User(object, withRelations: false)
                        friends.append(friend)
                    }
                    
                    self.friendsList = friends
                    callback?(users: friends)
                } else if error != nil {
                    println(error)
                }
            })
        } else {
            callback?(users: self.friendsList)
        }
    }
    
    func getSharedPosts(callback: ((posts: [Post]) -> Void)?) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        query.whereKey("sharedUsers", equalTo: self.parse)
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects as [PFObject] {
                    posts.append(Post(object, withRelations: false))
                }
                
                callback!(posts: posts)
            } else if error != nil {
                println(error)
            }
        })
    }
    
    // MARK: Class Methods
    class func current(relations: Bool = false) -> User {
        return User(PFUser.currentUser(), withRelations: relations)
    }
    
    class func logout() {
        PFUser.logOut()
    }
}
