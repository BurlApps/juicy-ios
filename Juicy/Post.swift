//
//  Post.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Post: NSObject {
    
    // MARK: Instance Variables
    var id: String!
    var age: Int!
    var likes: Int!
    var image: String!
    var juicy: Bool!
    var created: NSDate!
    var creator: User!
    var aboutUsers: [User]!
    private var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ post: PFObject, withRelations: Bool = false) {
        self.init(post, withRelations: withRelations)
        
        self.parse = post
        self.id = post.objectForKey("objectId") as String
        self.age = post.objectForKey("age") as Int
        self.likes = post.objectForKey("likes") as Int
        self.juicy = post.objectForKey("juicy") as Bool
        self.created = post.objectForKey("createdAt") as NSDate
        self.image = (post.objectForKey("image") as PFFile).url
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Instance Methods
    func getCreator()-> User {
        let creator: PFUser = self.parse.objectForKey("creator") as PFUser
        let creatorUser: User = User(creator, withRelations: false)
        self.creator = creatorUser
        return creatorUser
    }
    
    func getAboutUsers() -> [User] {
        var users: [User] = []
        var query: PFQuery = (self.parse.objectForKey("aboutUsersRelation") as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            for object in objects as [PFUser] {
                let user = User(object)
                users.append(user)
            }
        })
        
        self.aboutUsers = users
        return users
    }
}
