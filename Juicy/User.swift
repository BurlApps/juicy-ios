//
//  User.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    
    // MARK: Instance Variables
    var id: String!
    var username: String!
    var screenName: String!
    var facebook: String!
    var created: NSDate!
    var savedPosts: [Post]!
    private var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ user: PFUser, withRelations: Bool = false) {
        self.init(user, withRelations: withRelations)
        
        self.parse = user
        self.id = user.objectForKey("user") as? String
        self.screenName = user.objectForKey("screenName") as? String
        self.username = user.objectForKey("username") as? String
        self.facebook = user.objectForKey("authData") as? String
        self.created = user.objectForKey("createdAt") as? NSDate
        
        if withRelations {
            self.getSavedPosts()
        }
    }
    
    // MARK: Instance Methods
    func getSavedPosts() -> [Post] {
        var posts: [Post] = []
        var query: PFQuery = (self.parse.objectForKey("savedpostsRelation") as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            for object in objects as [PFObject] {
                let post = Post(object)
                posts.append(post)
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
