//
//  Post.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

private var queueSize = 5
private var saveQueue = NSMutableSet()

class Post: NSObject {
    
    // MARK: Instance Variables
    var likes: Int!
    var shares: Int!
    var karma: Int!
    var location: String!
    var content: [AnyObject]!
    var juicy: Bool!
    var creator: User!
    var aboutUsers: [User]!
    var background: UIColor!
    var parse: PFObject!
    
    // MARK: Private Instance Variables
    var image: NSURL!
    var cachedImage: UIImage!
    
    // MARK: Convenience Methods
    convenience init(_ post: PFObject, withRelations: Bool = false) {
        self.init()
        
        self.parse = post
        self.likes = post["likes"] as Int
        self.shares = post["shares"] as Int
        self.karma = post["karma"] as Int
        self.location = post["location"] as? String
        self.juicy = post["juicy"] as Bool
        self.content = post["content"] as [AnyObject]
        
        if let image = post["image"] as? PFFile {
            self.image = NSURL(string: image.url)
        }
        
        if let background = post["background"] as? [CGFloat] {
            let red = background[0]/255
            let green = background[1]/255
            let blue = background[2]/255
            
            self.background = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Class Methods
    class func create(content: [AnyObject], aboutUsers: [User], image: UIImage!, background: UIColor!, creator: User, location: String!) {
        var post = PFObject(className: "Posts")
        
        // Set Optional Content
        if background != nil {
            var colorComp = CGColorGetComponents(background.CGColor)
            
            post["background"] = [
                Int(colorComp[0] * 255),
                Int(colorComp[1] * 255),
                Int(colorComp[2] * 255)
            ]
        }
        
        if image != nil {
            var imageData = UIImagePNGRepresentation(image)
            var imageFile = PFFile(name: "image.png", data: imageData)
            
            post["image"] = imageFile
        }
        
        if location != nil {
            post["location"] = location
        }
        
        // Set Core Content
        post["show"] = true
        post["content"] = content
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
                PFCloud.callFunctionInBackground("feed", withParameters: [
                    "limit": limit,
                    "skip": skip
                ], block:{ (objects: AnyObject!, error: NSError!) -> Void in
                    if error == nil {
                        var posts: [Post] = []
                        
                        for object in objects as [PFObject] {
                            posts.append(Post(object, withRelations: withRelations))
                        }
                        
                        callback(posts: posts)
                    } else if error != nil {
                        println(error)
                    }
                    
                    return ()
                })
            } else {
                println(error)
            }
        })
    }
    
    class func topPosts(limit: Int = 10, callback: (posts: [Post]) -> Void) {
        var postQuery = PFQuery(className: "Posts")
        
        postQuery.limit = limit
        postQuery.orderByDescending("karma")
        
        postQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var posts: [Post] = []
                
                for object in objects as [PFObject] {
                    posts.append(Post(object, withRelations: false))
                }
                
                callback(posts: posts)
            } else if error != nil {
                println(error)
            }
            
            return ()
        }
    }
    
    class func batchSave(force: Bool = false) {
        Post.batchSave(force, nil)
    }
    
    class func batchSave(force: Bool, callback: ((success: Bool, error: NSError!) -> Void)!) {
        if saveQueue.count != 0 {
            if force || saveQueue.count > queueSize {
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
        self.parse.incrementKey("shares", byAmount: contacts.count + 1)
        self.like(user, amount: contacts.count + 1)
        
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
        if self.cachedImage == nil {
            let request = NSURLRequest(URL: self.image)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    self.cachedImage = UIImage(data: data)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        // Makes a 1x1 graphics context and draws the image into it
                        UIGraphicsBeginImageContext(CGSizeMake(1,1))
                        let context = UIGraphicsGetCurrentContext()
                        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.cachedImage.CGImage)
                        UIGraphicsEndImageContext()
                        
                        // Now the image will have been loaded and decoded
                        // and is ready to rock for the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(image: self.cachedImage)
                        })
                    })
                } else {
                    println(error)
                }
            })
        } else {
            callback(image: self.cachedImage)
        }
    }
    
    // MARK: Extra Utilities For Future
    func getCreator()-> User! {
        var creator: PFUser! = self.parse["creator"] as PFUser
        
        if creator == nil {
            return nil
        }
            
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
