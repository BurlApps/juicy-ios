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
    var displayName: String!
    var savedPosts: [Post]!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ user: PFUser, withRelations: Bool) {
        self.init()
        
        self.parse = user
        self.username = user["username"] as String
        self.displayName = user["displayName"] as? String
        
        if withRelations {
            self.getSavedPosts()
        }
    }
    
    // MARK: Instance Methods
    func getFacebookInfo() {
        var fbRequest = FBRequest.requestForMe()
        fbRequest.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if !error && result != nil {
                let fbUser = result as FBGraphObject
                self.displayName = fbUser["name"] as String
                self.parse["displayName"] = self.displayName
                self.parse.saveInBackground()
            } else if error {
                println(error)
            }
        })
    }
    
    func getSavedPosts() -> [Post] {
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
            } else if error {
                println(error)
            }
        })
        
        self.savedPosts = posts
        return posts
    }
    
    // MARK: Class Methods
    class func current(withRelations: Bool) -> User {
        return User(PFUser.currentUser(), withRelations: withRelations)
    }
}
