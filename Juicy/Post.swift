//
//  Post.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

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

    class func find(exclude: User, withRelations: Bool = true, limit: Int = 15, skip: Int = 0, callback: (posts: [Post]) -> Void) {
        var posts: [Post] = []
        var query = PFQuery(className: "Posts")
        
        query.limit = limit
        query.skip = skip
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache
        query.orderByDescending("createdAt")
        
        // TODO: Uncomment when posting works
        //query.whereKey("creator", notEqualTo: exclude.parse)
        //query.whereKey("likedUsers", notEqualTo: exclude.parse)
        //query.whereKey("nopedUsers", notEqualTo: exclude.parse)
        
        // TODO: All queries below are part of compound or query
        // TODO: Query for friends that have liked it
        // TODO: Query for geo location from where u are
        // TODO: Query for about my friends
        // TODO: Query for about me
        // TODO: Query for hotness calculated by karma (can be negative)
        // TODO: Query for newest posts
        
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
    func getImage(callback: (image: UIImage) -> Void) {
        let request = NSURLRequest(URL: self.image)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if !error {
                let image = UIImage(data: data)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    // Make a trivial (1x1) graphics context,
                    // and draw the image into it
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
