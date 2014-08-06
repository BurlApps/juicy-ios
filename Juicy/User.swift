//
//  User.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    var id: String?
    var username: String?
    var facebook: String?
    var created: NSDate?
    var likedCards: [Card]?
    
    convenience init(user: PFUser) {
        self.init(user: user)
        
        self.id = user["objectId"] as? String
        self.username = user["username"] as? String
        self.facebook = user["authData"] as? String
        self.created = user["createdAt"] as? NSDate
    }
   
    // TODO: Should I use PFRelations?
    func getLikedCards() -> [Card] {
        var cards: [Card] = []
        var query: PFQuery = PFQuery(className: "Cards")
        
        query.whereKey("savedIds", equalTo: self.id)
        query.orderByDescending("createdAt")
        
        for object in query.findObjects() {
            let card = Card(options: object as PFObject)
            cards.append(card)
        }
        
        self.likedCards = cards
        return cards
    }
}
