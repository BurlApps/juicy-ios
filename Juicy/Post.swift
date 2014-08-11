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
    var content: String!
    var juicy: Bool!
    var creator: User!
    var aboutUsers: [User]!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ post: PFObject, withRelations: Bool = false) {
        self.init()
        
        self.parse = post
        self.likes = post["likes"] as Int
        self.juicy = post["juicy"] as Bool
        self.content = post["content"] as String
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Class Methods
    class func find(exclude: User, withRelations: Bool, limit: Int = 15, skip: Int = 0, callback: (posts: [Post]) -> Void) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        query.limit = limit
        query.skip = skip
        query.cachePolicy = kPFCachePolicyCacheElseNetwork
        
        query.orderByDescending("createdAt")
        //query.whereKey("creator", notEqualTo: exclude.parse)
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if !error && !objects.isEmpty {
                for object in objects as [PFObject] {
                    posts.append(Post(object, withRelations: withRelations))
                }
                
                callback(posts: posts)
            } else if error {
                println(error)
            }
        })
    }
    
    // MARK: Instance Methods
    func getBackground()-> PFImageView {
        var imageView = PFImageView()
        imageView.image = UIImage()
        imageView.file = self.parse["image"] as PFFile
        imageView.loadInBackground()
        return imageView
    }
    
    func getCreator()-> User {
        var creator: PFUser = self.parse["creator"] as PFUser
        creator.fetch()
        
        let creatorUser: User = User(creator, withRelations: false)
        self.creator = creatorUser
        return creatorUser
    }
    
    func getAboutUsers() -> [User] {
        var users: [User] = []
        var query: PFQuery = (self.parse["aboutUsers"] as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.cachePolicy = kPFCachePolicyCacheElseNetwork
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in         
            if !error && !objects.isEmpty {
                for object in objects as [PFUser] {
                    let user = User(object, withRelations: false)
                    users.append(user)
                }
            } else if error {
                println(error)
            }
        })
        
        self.aboutUsers = users
        return users
    }
}
