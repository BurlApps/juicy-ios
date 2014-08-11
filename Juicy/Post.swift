//
//  Post.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Post: NSObject {
    
    // MARK: Instance Variables
    var age: Int!
    var likes: Int!
    var image: String!
    var juicy: Bool!
    var creator: User!
    var aboutUsers: [User]!
    private var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ post: PFObject, withRelations: Bool = false) {
        self.init()
        
        self.parse = post
        self.likes = post["likes"] as Int
        self.juicy = post["juicy"] as Bool
        self.image = (post["image"] as? PFFile)?.url
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Class Methods
    class func find(exclude: User, withRelations: Bool, callback: (posts: [Post]) -> Void) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        //query.whereKey("username", notEqualTo: exclude.username)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if !error {
                for object in objects {
                    posts.append(Post(object as PFObject, withRelations: withRelations))
                }
                
                callback(posts: posts)
            } else {
                NSLog("Error: %@ %@", error, error.userInfo)
            }
        })
    }
    
    // MARK: Instance Methods
    func getCreator()-> User {
        let creator: PFUser = self.parse["creator"] as PFUser
        let creatorUser: User = User(creator, withRelations: false)
        self.creator = creatorUser
        return creatorUser
    }
    
    func getAboutUsers() -> [User] {
        var users: [User] = []
        var query: PFQuery = (self.parse["aboutUsers"] as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            for object in objects as [PFUser] {
                let user = User(object, withRelations: false)
                users.append(user)
            }
        })
        
        self.aboutUsers = users
        return users
    }
}
