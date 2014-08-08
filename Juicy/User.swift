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
    var savedCards: [Card]!
    private var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(user: PFUser, withRelations: Bool = false) {
        self.init(user: user, withRelations: withRelations)
        
        self.parse = user
        self.id = user.objectForKey("user") as? String
        self.screenName = user.objectForKey("screenName") as? String
        self.username = user.objectForKey("username") as? String
        self.facebook = user.objectForKey("authData") as? String
        self.created = user.objectForKey("createdAt") as? NSDate
        
        if withRelations {
            self.getSavedCards()
        }
    }
    
    // MARK: Instance Methods
    func getSavedCards() -> [Card] {
        var cards: [Card] = []
        var query: PFQuery = (self.parse.objectForKey("savedCardsRelation") as PFRelation).query()
        
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) in
            for object in objects as [PFObject] {
                let card = Card(card: object)
                cards.append(card)
            }
        })
        
        self.savedCards = cards
        return cards
    }
    
    // MARK: Class Methods
    class func current(withRelations: Bool) -> User {
        return User(user: PFUser.currentUser(), withRelations: withRelations)
    }
    
}
