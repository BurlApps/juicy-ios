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
            if error == nil && result != nil {
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
        if self.parse["friends"] != nil {
            var friends: [User] = []
            var friendsRelation = self.parse["friends"] as PFRelation
            var query = friendsRelation.query()
            
            query.cachePolicy = kPFCachePolicyNetworkElseCache
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
                if error == nil && !objects.isEmpty {
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
        }
    }
    
    func getSavedPosts(callback: ((posts: [Post]) -> Void)?) {
        var posts: [Post] = []
        var query: PFQuery = (self.parse["savedPosts"] as PFRelation).query()
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            if error == nil && !objects.isEmpty {
                for object in objects as [PFObject] {
                    let post = Post(object)
                    posts.append(post)
                }
                
                self.savedPosts = posts
                callback?(posts: posts)
            } else if error != nil {
                println(error)
            }
        })
    }
    
    // MARK: Class Methods
    class func current(withRelations: Bool) -> User {
        return User(PFUser.currentUser(), withRelations: withRelations)
    }
}
