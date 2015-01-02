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
    var abTester: String!
    var sharedPosts: [Post]!
    var friendsList: [User]!
    var registered: Bool!
    var onboarded: Bool!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ user: PFUser, withRelations: Bool = false) {
        self.init()
        
        self.parse = user
        self.username = user["username"] as? String
        self.displayName = user["displayName"] as? String
        self.abTester = user["abTester"] as? String
        self.name = user["name"] as? String
        self.registered = user["registered"] as? Bool
        self.onboarded = user["onboarded"] as? Bool
        
        if withRelations {
            self.getFriendsList(nil)
        }
    }
    
    // MARK: Class Methods
    class func current(relations: Bool = false) -> User! {
        if let user = PFUser.currentUser() {
            return User(user, withRelations: relations)
        } else {
            return nil
        }
    }
    
    class func logout() {
        if PFUser.currentUser() != nil {
            PFUser.logOut()
        }
    }
    
    // MARK: Instance Methods
    func logout() {
        PFUser.logOut()
    }
    
    func didOnboarding() {
        self.parse["registered"] = true
        self.parse["onboarded"] = true
        self.parse.saveInBackgroundWithBlock(nil)
    }
    
    func getFriendsList(callback: ((users: [User]) -> Void)!) {
        if self.friendsList == nil {
            if(self.parse["friends"] != nil) {
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
                callback?(users: [])
            }
        } else {
            callback?(users: self.friendsList)
        }
    }
    
    func getMyPosts(callback: ((posts: [Post]) -> Void)!) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        query.whereKey("show", equalTo: true)
        query.whereKey("creator", equalTo: self.parse)
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
    
    func getLikedPosts(callback: ((posts: [Post]) -> Void)!) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        query.whereKey("show", equalTo: true)
        query.whereKey("likedUsers", equalTo: self.parse)
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
}
