//
//  Post.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

private var saveQueue = NSMutableSet()

class Post: NSObject {
    
    // MARK: Instance Variables
    var likes: Int!
    var karma: Int!
    var content: [AnyObject]!
    var image: NSURL!
    var juicy: Bool!
    var creator: User!
    var aboutUsers: [User]!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ post: PFObject, withRelations: Bool = false) {
        self.init()
        
        self.parse = post
        self.likes = post["likes"] as Int
        self.karma = post["karma"] as Int
        self.juicy = post["juicy"] as Bool
        self.image = NSURL(string: (self.parse["image"] as PFFile).url)
        self.content = post["content"] as [AnyObject]
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Class Methods
    class func create(content: [AnyObject], aboutUsers: [User], image: UIImage, creator: User) {
        var post = PFObject(className: "Posts")
        var imageData = UIImagePNGRepresentation(image)
        var imageFile = PFFile(name: "image.png", data: imageData)
        
        // Set Defaults
        post["likes"] = 0
        post["karma"] = 0
        post["juicy"] = false
        post["show"] = true
        
        // Set Content
        post["content"] = content
        post["image"] = imageFile
        post["creator"] = creator.parse
        
        // Set About User Relation
        var aboutUsersRelation = post.relationForKey("aboutUsers")
        
        for user in aboutUsers {
            aboutUsersRelation.addObject(user.parse)
        }
        
        // Save Eventually
        post.saveInBackground()
    }

    class func find(current: User, withRelations: Bool = true, limit: Int = 15, skip: Int = 0, callback: (posts: [Post]) -> Void) {
        Post.batchSave(true, { (success, error) -> Void in
            if success == true && error == nil {
                var posts: [Post] = []
                var queries: [PFQuery] = []
                
                // TODO: All queries below are part of compound "or query"
                // TODO: Query for friends that have liked it (done)
                // TODO: Query for geo location from where u are
                // TODO: Query for about my friends (done)
                // TODO: Query for about me (done)
                // TODO: Query for hotness calculated by karma (done)
                // TODO: Query for newest posts (done)
                
                // About Me Query
                var aboutMeQuery = PFQuery(className: "Posts")
                aboutMeQuery.whereKey("aboutUsers", equalTo: current.parse)
                queries.append(aboutMeQuery)
                
                // About My Friends Query
                var aboutFriendsQuery = PFQuery(className: "Posts")
                let friendRelation = current.parse["friends"] as PFRelation
                aboutFriendsQuery.whereKey("aboutUsers", matchesQuery: friendRelation.query())
                queries.append(aboutFriendsQuery)

                // Base "Or Query"
                var query = PFQuery.orQueryWithSubqueries(queries)
                query.limit = limit
                query.skip = skip
                query.cachePolicy = kPFCachePolicyNetworkElseCache
                
                // TODO: uncomment in production
                query.whereKey("creator", notEqualTo: current.parse)
                query.whereKey("likedUsers", notEqualTo: current.parse)
                query.whereKey("nopedUsers", notEqualTo: current.parse)
                query.whereKey("show", equalTo: true)
                query.orderByDescending("createdAt")
                
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        for object in objects as [PFObject] {
                            posts.append(Post(object, withRelations: withRelations))
                        }
                        
                        callback(posts: posts)
                    } else if error != nil {
                        println(error)
                    }
                })
            } else {
                println(error)
            }
        })
    }
    
    class func batchSave(force: Bool = false) {
        Post.batchSave(force, nil)
    }
    
    class func batchSave(force: Bool, callback: ((success: Bool, error: NSError!) -> Void)!) {
        if saveQueue.count != 0 {
            if force || saveQueue.count > 30 {
                var posts: [PFObject] = []
                
                for post in saveQueue {
                    posts.append((post as Post).parse)
                    saveQueue.removeObject(post)
                }
                
                if callback != nil {
                    PFObject.saveAllInBackground(posts, callback)
                } else {
                    PFObject.saveAllInBackground(posts)
                }
            }
        } else {
            callback(success: true, error: nil)
        }
    }
    
    // MARK: Instance Methods
    func like(user: User, amount: Int = 1) {
        var likedRelation = self.parse.relationForKey("likedUsers")
        likedRelation.addObject(user.parse)
        
        self.parse.incrementKey("likes")
        self.parse.incrementKey("karma", byAmount: amount)
        
        saveQueue.addObject(self)
        Post.batchSave()
    }
    
    func nope(user: User) {
        var nopedRelation = self.parse.relationForKey("nopedUsers")
        nopedRelation.addObject(user.parse)
        
        self.parse.incrementKey("karma", byAmount: -1)
        
        saveQueue.addObject(self)
        Post.batchSave()
    }
    
    func share(user: User, contacts: NSArray) {
        var sharedRelation = self.parse.relationForKey("sharedUsers")
        sharedRelation.addObject(user.parse)
        self.like(user, amount: 2)
        
        self.parse.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            if success && error == nil {
                // Remove From Batch Save
                saveQueue.removeObject(self.parse)
      
                // Call ShareSms on Parse
                PFCloud.callFunctionInBackground("shareSms", withParameters: [
                    "post": self.parse.objectId,
                    "contacts": contacts,
                ], block: { (success, error) in
                    if error != nil {
                        println(error)
                    }
                })
            } else {
                println(error)
            }
        }
    }
    
    func getImage(callback: (image: UIImage) -> Void) {
        let request = NSURLRequest(URL: self.image)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                let image = UIImage(data: data)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    // Makes a 1x1 graphics context and draws the image into it
                    UIGraphicsBeginImageContext(CGSizeMake(1,1))
                    let context = UIGraphicsGetCurrentContext()
                    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage)
                    UIGraphicsEndImageContext()
                    
                    // Now the image will have been loaded and decoded
                    // and is ready to rock for the main thread
                    dispatch_async(dispatch_get_main_queue(), {
                        callback(image: image)
                    })
                })
            } else {
                println(error)
            }
        })
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
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in         
            if error == nil && !objects.isEmpty {
                for object in objects as [PFUser] {
                    let user = User(object, withRelations: false)
                    users.append(user)
                }
            } else if error != nil {
                println(error)
            }
        })
        
        self.aboutUsers = users
        return users
    }
}
