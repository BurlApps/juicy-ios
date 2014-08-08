//
//  Card.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Card: NSObject {
    
    // MARK: Instance Variables
    var id: String!
    var age: Int!
    var likes: Int!
    var image: UIImage!
    var juicy: Bool!
    var created: NSDate!
    var creator: User!
    var aboutUsers: [User]!
    private var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(card: PFObject, withRelations: Bool = false) {
        self.init(card: card, withRelations: withRelations)
        
        self.parse = card
        self.id = card.objectForKey("objectId") as? String
        self.age = card.objectForKey("age") as? Int
        self.likes = card.objectForKey("likes") as? Int
        self.image = card.objectForKey("image") as? UIImage
        self.juicy = card.objectForKey("juicy") as? Bool
        self.created = card.objectForKey("createdAt") as? NSDate
        
        if withRelations {
            self.getCreator()
            self.getAboutUsers()
        }
    }
    
    // MARK: Instance Methods
    func getCreator()-> User {
        let creator: PFUser = self.parse.objectForKey("creator") as PFUser
        let creatorUser: User = User(user: creator, withRelations: false)
        self.creator = creatorUser
        return creatorUser
    }
    
    func getAboutUsers() -> [User] {
        var users: [User] = []
        var query: PFQuery = (self.parse.objectForKey("aboutUsersRelation") as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            for object in objects as [PFUser] {
                let user = User(user: object)
                users.append(user)
            }
        })
        
        self.aboutUsers = users
        return users
    }
}
